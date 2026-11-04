/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.aspect_cj.plugins.weave_aspects

import std.collection.*
import std.convert.*
import std.fs.*
import std.io.*
import stdx.aspect_cj.*
import stdx.chir.*
import stdx.plugin.*

@CHIRPlugin
class WeaveAspects {
    var processInfos = ArrayList<OutputInfo>()
    var pkgInitFuncMangledNames = HashMap<String, String>()

    public override func run(pkg: Package): Bool {
        readAnnoInfo(pkg.name)
        callUpstreamPkgInitFunc(pkg)
        for (f in pkg.functions) {
            if (f.body.isNone()) {
                continue
            }
            for (pi in processInfos) {
                if (!meets(f, pi)) {
                    continue
                }
                weaveFuncBody(pkg, f, pi)
            }
        }
        return true
    }

    private func weaveFuncBody(pkg: Package, f: Function, pi: OutputInfo): Unit {
        let (args, success) = prepareArguments(f, pi)
        if (!success) {
            return
        }
        let callee = getCallee(pkg, pi, f, args)
        let funcCallCxt = FuncCallContext(args, Array<Type>(), computeThisTypeOfCallee(callee, args))
        if (pi.annoClassName == INSERT_AT_ENTRY_ANNO_CLASS_NAME) {
            let builder = CHIRBuilder(InsertPosition.AtStart(f.body.getOrThrow().entryBlock))
            builder.createApply(callee, funcCallCxt)
        } else if (pi.annoClassName == INSERT_AT_EXIT_ANNO_CLASS_NAME) {
            let visitor = InsertAtExitVisitor(callee, funcCallCxt)
            visitor.walk(f.body.getOrThrow())
        } else if (isReplaceBodyAnno(pi.annoClassName)) {
            let wrapperFunc = pkg.addFunction(f.funcType, f.identifierWithoutPrefix, f.srcCodeName, f.packageName)
            // Call sites keep ThisType. The replacement entry must stay a member of the same parent.
            if (let Some(parent) <- f.declaredParent) {
                parent.appendMethod(wrapperFunc)
            }
            // Add the original declaration attributes. addFunction already set PluginAdded;
            // that bit stays, it is not replaced.
            wrapperFunc.appendAttributesFrom(f)
            // GenerateVTable runs after this plugin. It collects every public or protected
            // method and matches candidates by srcCodeName plus signature. The renamed
            // original stays on the same parent, so it would share the wrapper's slot or
            // add a second one. Open dispatch and interface dispatch could then call the
            // original and skip the aspect. The wrapper keeps the copied VIRTUAL, OVERRIDE,
            // and visibility bits. The original leaves that candidate set.
            if (f.isMemberMethod()) {
                f.setOpen(false)
                f.setOverride(false)
                f.setAbstract(false)
                f.setPrivate()
            }
            f.replaceWith(wrapperFunc)
            wrapperFunc.initBody()
            let builder = CHIRBuilder(wrapperFunc.body.getOrThrow().entryBlock)
            let allocate = builder.createAllocate(f.funcType.returnType)
            wrapperFunc.returnValue = allocate.result
            if (args.size != 1) {
                for (i in 0..wrapperFunc.parameters.size) {
                    funcCallCxt.setArg(i, wrapperFunc.parameters[i])
                }
            }
            // Member functions cannot be passed as `original` directly. An Apply of a
            // member needs ThisType, and an instance `original` does not take the
            // receiver: the lambda captures this wrapper's receiver and calls the
            // old body with it.
            if (f.isMemberMethod()) {
                let bound = createBoundOriginal(builder, f, wrapperFunc)
                funcCallCxt.setArg(args.size - 1, bound)
            }
            let apply = builder.createApply(callee, funcCallCxt)
            builder.createStore(apply.result, allocate.result)
            builder.createExit()
            f.identifier = wrapperFunc.identifier + ".original"
        } else {
            printError("Unknown annotation class name '${pi.annoClassName}'.")
        }
    }

    // The value returned here is a lambda expression inside CA.foo, not a
    // package-level function. replaceFuncBody_into_instance.cj before weave:
    //
    //   class CA {
    //       @ReplaceBody[package: "default", class: "CA", method: "foo", isStatic: false, recursive: false]
    //       func aspect(x: Int64, original: (Int64) -> Int64): Int64 {
    //           let r = original(x)
    //           r
    //       }
    //       func foo(x: Int64): Int64 { x }   // CHIR type (CA&, Int64) -> Int64
    //   }
    //   main() { CA().foo(1) }
    //
    // After weave, `aspect` is unchanged. The old `foo` body stays on `CA`, renamed
    // foo.original and made private so it is not a vtable candidate. The name foo is a
    // new member of CA and keeps the original VIRTUAL/OVERRIDE bits. main's CA().foo(1)
    // enters this member. `bound` is a local lambda in this member's body:
    //
    //   class CA {
    //       @ReplaceBody[package: "default", class: "CA", method: "foo", isStatic: false, recursive: false]
    //       func aspect(x: Int64, original: (Int64) -> Int64): Int64 {
    //           let r = original(x)
    //           r
    //       }
    //       private func `foo.original`(x: Int64): Int64 { x }
    //       func foo(x: Int64): Int64 {
    //           let bound: (Int64) -> Int64 = { x => this.`foo.original`(x) }
    //           this.aspect(x, bound)
    //       }
    //   }
    //
    // `original` does not take the receiver. The lambda captures the wrapper's
    // `this` and passes it, with ThisType, to foo.original. A static member has
    // no receiver to capture; ThisType comes from the parent type.
    //
    // Create the lambda after replaceWith. That rewrite only retargets users
    // that already exist, so the Apply inside the lambda stays on foo.original.
    // Creating it earlier would retarget that Apply to foo and recurse.
    private func createBoundOriginal(builder: CHIRBuilder, original: Function, wrapper: Function): Value {
        var paramTypes = original.funcType.paramTypes
        var capturedReceiver: ?Value = None
        if (original.isInstanceMemberMethod()) {
            let (_, rest) = paramTypes.splitAt(1)
            paramTypes = rest
            capturedReceiver = wrapper.parameters[0]
        }
        let boundTy = FuncType.get(paramTypes, original.funcType.returnType)
        let lambda = builder.createLambda(boundTy, wrapper.identifierWithoutPrefix + ".bound", "original")
        let lambdaBuilder = CHIRBuilder(lambda.body.entryBlock)
        let retSlot = lambdaBuilder.createAllocate(boundTy.returnType)
        lambda.returnValue = retSlot.result
        let callArgs = ArrayList<Value>()
        let thisType = match (capturedReceiver) {
            case Some(recv) =>
                callArgs.add(recv)
                addRefIfFuncIsMutOrClass(recv.ty, original)
            case None => addRefIfFuncIsMutOrClass(original.outerType.getOrThrow(), original)
        }
        for (param in lambda.parameters) {
            callArgs.add(param)
        }
        let callCtx = FuncCallContext(callArgs.toArray(), Array<Type>(), Some(thisType))
        let apply = lambdaBuilder.createApply(original, callCtx)
        lambdaBuilder.createStore(apply.result, retSlot.result)
        lambdaBuilder.createExit()
        return lambda.result
    }

    private func computeThisTypeOfCallee(callee: Function, args: Array<Value>): ?Type {
        if (callee.isMemberMethod()) {
            if (callee.isStatic()) {
                return addRefIfFuncIsMutOrClass(callee.outerType.getOrThrow(), callee)
            }
            return args[0].ty
        }
        return None
    }

    private func getCallee(pkg: Package, pi: OutputInfo, f: Function, args: Array<Value>): Function {
        if (let Some(v) <- pkg.getSpecifiedFunction(pi.insert.methodMangledName)) {
            return v
        }
        let paramTypes = mapArrayTo(args, {arg => arg.ty})
        var returnType: Type = UnitType.get()
        if (isReplaceBodyAnno(pi.annoClassName)) {
            returnType = f.funcType.returnType
        }
        let funcType = FuncType.get(paramTypes, returnType)
        let callee = pkg.addFunction(funcType, pi.insert.methodMangledName, "", pi.insert.packageName)
        callee.setImported(true)
        return callee
    }

    private func printError(message: String): Unit {
        println(message)
    }

    private func prepareArguments(f: Function, pi: OutputInfo): (Array<Value>, Bool) {
        var expectedParamsNum = pi.insert.paramsNum
        if (isReplaceBodyAnno(pi.annoClassName)) {
            expectedParamsNum -= 1
        }
        let args = ArrayList<Value>()
        if (expectedParamsNum != 0) {
            if (f.parameters.size != expectedParamsNum) {
                printError("Parameter count mismatch: target function '${f.srcCodeName}' has '${f.parameters.size}' parameters, expected '${expectedParamsNum}' parameters from aspect metadata '${pi.insert.methodMangledName}'.")
                return (Array<Value>(), false)
            }
            for (param in f.parameters) {
                args.add(param)
            }
        }
        if (isReplaceBodyAnno(pi.annoClassName)) {
            args.add(f)
        }
        return (args.toArray(), true)
    }

    private func callUpstreamPkgInitFunc(pkg: Package): Unit {
        let curPkgInitFunc = pkg.packageInitFunc.getOrThrow()
        let bb = curPkgInitFunc.body.getOrThrow().entryBlock
        let builder = CHIRBuilder(InsertPosition.AtStart(bb))
        for ((pkgName, initFuncMangledName) in pkgInitFuncMangledNames) {
            if (pkgName == pkg.name) {
                continue
            }
            // Reuse an existing declaration when present (e.g. target already imported the
            // aspect package) to avoid duplicated CHIR identifiers. Always emit the apply:
            // presence of the symbol does not guarantee the current package init already
            // calls it (indirect import / opt / DCE). Package inits are expected to be
            // idempotent, so an extra apply is safe.
            let importedInitFunc = if (let Some(existing) <- pkg.getSpecifiedFunction(initFuncMangledName)) {
                existing
            } else {
                let funcType = FuncType.get(Array<Type>(), UnitType.get())
                let added = pkg.addFunction(funcType, initFuncMangledName, "", pkgName)
                added.setImported(true)
                added
            }
            let funcCallCxt = FuncCallContext(Array<Value>(), Array<Type>(), None)
            builder.createApply(importedInitFunc, funcCallCxt)
        }
    }

    private func meets(f: Function, pi: OutputInfo): Bool {
        if (pi.to.packageName != f.packageName) {
            return false
        }
        if (!outerTypeNameMeets(f, pi)) {
            return false
        }
        if (pi.to.methodName != f.srcCodeName) {
            return false
        }
        if (pi.to.isStatic != f.isStatic()) {
            return false
        }
        var params = f.parameters
        if (f.isInstanceMemberMethod()) {
            (_, params) = params.splitAt(1)
        }
        let paramTypes = mapArrayTo(params, {param => param.ty})
        let funcTypeStr = FuncType.get(paramTypes, f.funcType.returnType).qualifiedName
        if (pi.to.funcTypeStr != funcTypeStr) {
            return false
        }
        return true
    }

    private func outerTypeNameMeets(f: Function, pi: OutputInfo): Bool {
        if (getFuncOuterTypeName(f) == pi.to.className) {
            return true
        }
        if (let Some(outerType) <- f.outerType && pi.to.recursively) {
            let superTypes: Array<ClassLikeType>
            if (let Some(bt) <- (outerType as BuiltinType)) {
                superTypes = bt.getSuperTypesRecusively()
            } else if (let Some(ct) <- (outerType as CustomType)) {
                superTypes = ct.getSuperTypesRecusively()
            } else {
                return false
            }
            for (superType in superTypes) {
                if (superType.def.srcCodeName == pi.to.className) {
                    return true
                }
            }
        }
        return false
    }

    private func readAnnoInfo(curPkgName: String): Unit {
        Directory.walk(
            Path("."),
            {
                fileInfo =>
                let fileName = fileInfo.name
                let results = fileName.split(PACKAGE_NAME_CONNECTOR)
                if (results.size != 2) {
                    return true
                }
                if (results[1] != curPkgName + ANNO_INFO_FILE_SUFFIX) {
                    return true
                }
                try (f = File(Path(fileName), OpenMode.Read)) {
                    let reader = StringReader(f)
                    while (let Some(pkgName) <- reader.readln()) {
                        // Package init function mangled name
                        let initFuncMangledName = reader.readln().getOrThrow()
                        pkgInitFuncMangledNames.add(pkgName, initFuncMangledName)
                        // Anno class name
                        let annoClassName = reader.readln().getOrThrow()
                        // Insert
                        let inPackageName = reader.readln().getOrThrow()
                        let methodMangledName = reader.readln().getOrThrow()
                        let paramsNum = Int64.parse(reader.readln().getOrThrow())
                        let isMemberFunc = Bool.parse(reader.readln().getOrThrow())
                        let inIsStatic = Bool.parse(reader.readln().getOrThrow())
                        let insert = Insert(inPackageName, methodMangledName, paramsNum, isMemberFunc, inIsStatic)
                        // To
                        let toPackageName = reader.readln().getOrThrow()
                        let className = reader.readln().getOrThrow()
                        let methodName = reader.readln().getOrThrow()
                        let funcTypeStr = reader.readln().getOrThrow()
                        let toIsStatic = Bool.parse(reader.readln().getOrThrow())
                        let recursively = Bool.parse(reader.readln().getOrThrow())
                        let to = To(toPackageName, className, methodName, funcTypeStr, toIsStatic, recursively)
                        // OutputInfo
                        let processInfo = OutputInfo(annoClassName, insert, to)
                        processInfos.add(processInfo)
                    }
                } catch (_: Exception) {}
                return true
            }
        )
    }
}

internal class InsertAtExitVisitor <: CHIRVisitor {
    let callee: Function
    let funcCallCxt: FuncCallContext
    public init(callee: Function, funcCallCxt: FuncCallContext) {
        this.callee = callee
        this.funcCallCxt = funcCallCxt
    }
    public override func action(e: Expression): IRActionMode {
        if (e.isLambda()) {
            return IRActionMode.Skip
        }
        if (e.isExit()) {
            let builder = CHIRBuilder(InsertPosition.Before(e))
            builder.createApply(callee, funcCallCxt)
        }
        return IRActionMode.Continue
    }
}
