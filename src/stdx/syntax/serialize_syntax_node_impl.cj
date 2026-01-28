/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.syntax

protected func serializePkg(node: Package): Array<UInt8> {
    var fb = Builder(0)
    let srcFiles = node.srcFile
    let syntaxNodeImplList = Array<SyntaxNodeImpl>(srcFiles.size, {i => srcFiles[i].nodeImpl})

    let childrenType = serializeChildrenType(fb, syntaxNodeImplList)
    let children = serializeChildren(fb, syntaxNodeImplList)

    let pkgNodeImpl = SyntaxNodeFormat_NonTerminal.createNonTerminal(
        fb, 
        node.nodeImpl.id,
        SyntaxNodeFormat_NodeImplKind.NodeImplKind_PACKAGE,
        childrenType,
        children)
        
    fb.finish(pkgNodeImpl)
    fb.finishedBytes()
}

private func serializeChildrenType(fb: Builder, syntaxNodeImplList: Array<SyntaxNodeImpl>): UInt32 {
    if (syntaxNodeImplList.size == 0) {
        return 0
    }
    fb.startVector(2, syntaxNodeImplList.size, 2)
    for (i in syntaxNodeImplList.size - 1..=0 : -1) {
        match (syntaxNodeImplList[i]) {
            case nt: NonTerminal => 
                fb.prependUInt8(EnumSyntaxNodeFormat_SyntaxNodeImplValues(SyntaxNodeFormat_SyntaxNodeImpl.SyntaxNodeImpl_NONTERMINAL))
            case vt: ValuedTerminal => 
                fb.prependUInt8(EnumSyntaxNodeFormat_SyntaxNodeImplValues(SyntaxNodeFormat_SyntaxNodeImpl.SyntaxNodeImpl_VALUEDTERMINAL))
            case vt: RepeatedTerminal => 
                fb.prependUInt8(EnumSyntaxNodeFormat_SyntaxNodeImplValues(SyntaxNodeFormat_SyntaxNodeImpl.SyntaxNodeImpl_REPEATEDTERMINAL))
            case t: Terminal => 
                fb.prependUInt8(EnumSyntaxNodeFormat_SyntaxNodeImplValues(SyntaxNodeFormat_SyntaxNodeImpl.SyntaxNodeImpl_TERMINAL))
            case _ => fb.prependUInt8(EnumSyntaxNodeFormat_SyntaxNodeImplValues(SyntaxNodeFormat_SyntaxNodeImpl.SyntaxNodeImpl_NONE))
        }
    }
    return fb.endVector(syntaxNodeImplList.size)
}

private func serializeChildren(fb: Builder, syntaxNodeImplList: Array<SyntaxNodeImpl>): UInt32 {
    if (syntaxNodeImplList.size == 0) {
        return 0
    }
    let SyntaxNodeImplOffset = Array<UInt32>(syntaxNodeImplList.size, repeat: 0) 
    for (i in syntaxNodeImplList.size - 1..=0 : -1) {
        match (syntaxNodeImplList[i]) {
            case nt: NonTerminal => 
                SyntaxNodeImplOffset[i] = serializeNonTerminal(fb, nt)
                // fb.prependUOffsetT(serializeNonTerminal(fb, nt))
            case vt: ValuedTerminal => 
                SyntaxNodeImplOffset[i] = serializeValuedTerminal(fb, vt)
                // fb.prependUOffsetT(serializeValuedTerminal(fb, vt))
            case rt: RepeatedTerminal => 
                SyntaxNodeImplOffset[i] = serializeRepeatedTerminal(fb, rt)
                // fb.prependUOffsetT(serializeRepeatedTerminal(fb, rt))
            case t: Terminal => 
                SyntaxNodeImplOffset[i] = serializeTerminal(fb, t)
                // fb.prependUOffsetT(serializeTerminal(fb, t))
            case _ => throw Exception("serializeChildren error")
        }
    }
    fb.startVector(4, syntaxNodeImplList.size, 4)
    for (i in syntaxNodeImplList.size - 1..=0 : -1) {
        fb.prependUOffsetT(SyntaxNodeImplOffset[i])
    }
    return fb.endVector(syntaxNodeImplList.size)
}

private func serializeNonTerminal(fb: Builder, nt: NonTerminal): UInt32  {
    let childrenType = serializeChildrenType(fb, nt.children)
    let children = serializeChildren(fb, nt.children)
    return SyntaxNodeFormat_NonTerminal.createNonTerminal(
        fb, 
        nt.id,
        syntaxNodeKindToNodeImplKind(nt.kind),
        childrenType,
        children)
}

private func serializeValuedTerminal(fb: Builder, vt: ValuedTerminal): UInt32  {
    let value = fb.createString(vt.value)
    return SyntaxNodeFormat_ValuedTerminal.createValuedTerminal(
        fb, 
        vt.id,
        syntaxNodeKindToNodeImplKind(vt.kind),
        value)
}

private func serializeRepeatedTerminal(fb: Builder, rt: RepeatedTerminal): UInt32  {
    return SyntaxNodeFormat_RepeatedTerminal.createRepeatedTerminal(
        fb, 
        rt.id,
        syntaxNodeKindToNodeImplKind(rt.kind),
        rt.repeat)
}

private func serializeTerminal(fb: Builder, t: Terminal): UInt32  {
    return SyntaxNodeFormat_Terminal.createTerminal(
        fb, 
        t.id,
        syntaxNodeKindToNodeImplKind(t.kind))
}

private func syntaxNodeKindToNodeImplKind(kind: SyntaxNodeKind): SyntaxNodeFormat_NodeImplKind {
    match (kind) {
        case SyntaxNodeKind.File => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_FILE
        case SyntaxNodeKind.Package => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_PACKAGE
        case SyntaxNodeKind.FeaturesDirective => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_FEATURESDIRECTIVE
        case SyntaxNodeKind.FeaturesSet => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_FEATURESSET
        case SyntaxNodeKind.FeatureId => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_FEATUREID
        case SyntaxNodeKind.PackageSpec => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_PACKAGESPEC
        case SyntaxNodeKind.PackagePrefixes => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_PACKAGEPREFIXES
        case SyntaxNodeKind.CatchPattern => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_CATCHPATTERN
        case SyntaxNodeKind.Argument => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_ARGUMENT
        case SyntaxNodeKind.Annotation => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_ANNOTATION
        case SyntaxNodeKind.AnnotationList => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_ANNOTATIONLIST
        case SyntaxNodeKind.TypeArguments => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_TYPEARGUMENTS
        case SyntaxNodeKind.ModifierList => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_MODIFIERLIST
        case SyntaxNodeKind.ParameterList => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_PARAMETERLIST
        case SyntaxNodeKind.GenericConstraints => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_GENERICCONSTRAINTS
        case SyntaxNodeKind.GenericConstraint => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_GENERICCONSTRAINT
        case SyntaxNodeKind.MatchCase => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_MATCHCASE
        case SyntaxNodeKind.MatchCaseBody => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_MATCHCASEBODY
        case SyntaxNodeKind.Pattern => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_PATTERN
        case SyntaxNodeKind.Body => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_BODY
        case SyntaxNodeKind.DisjunctionCondition => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_DISJUNCTIONCONDITION
        case SyntaxNodeKind.ConjunctionCondition => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_CONJUNCTIONCONDITION
        case SyntaxNodeKind.ParenCondition => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_PARENCONDITION
        case SyntaxNodeKind.LetPattern => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_LETPATTERN
        case SyntaxNodeKind.AtomicCondition => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_ATOMICCONDITION
        case SyntaxNodeKind.TokenList => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_TOKENLIST
        case SyntaxNodeKind.Comment => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_COMMENT
        case SyntaxNodeKind.CommentGroup => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_COMMENTGROUP
        case SyntaxNodeKind.CommentGroupList => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_COMMENTGROUPLIST
        case SyntaxNodeKind.Modifier => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_MODIFIER
        case SyntaxNodeKind.GenericParam => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_GENERICPARAM
        case SyntaxNodeKind.ImportSpec => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_IMPORTSPEC
        case SyntaxNodeKind.ImportAlias => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_IMPORTALIAS
        case SyntaxNodeKind.ImportAll => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_IMPORTALL
        case SyntaxNodeKind.ImportMulti => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_IMPORTMULTI
        case SyntaxNodeKind.ImportSingle => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_IMPORTSINGLE
        case SyntaxNodeKind.PrimitiveType => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_PRIMITIVETYPE
        case SyntaxNodeKind.RefType => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_REFTYPE
        case SyntaxNodeKind.FuncType => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_FUNCTYPE
        case SyntaxNodeKind.ThisType => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_THISTYPE
        case SyntaxNodeKind.ParenType => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_PARENTYPE
        case SyntaxNodeKind.QualifiedType => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_QUALIFIEDTYPE
        case SyntaxNodeKind.OptionType => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_OPTIONTYPE
        case SyntaxNodeKind.OptionalType => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_OPTIONALTYPE
        case SyntaxNodeKind.VArrayType => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_VARRAYTYPE
        case SyntaxNodeKind.TupleType => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_TUPLETYPE
        case SyntaxNodeKind.CompositeType => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_COMPOSITETYPE
        case SyntaxNodeKind.MainDecl => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_MAINDECL
        case SyntaxNodeKind.VarDecl => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_VARDECL
        case SyntaxNodeKind.FuncDecl => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_FUNCDECL
        case SyntaxNodeKind.FuncParam => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_FUNCPARAM
        case SyntaxNodeKind.LambdaParam => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_LAMBDAPARAM
        case SyntaxNodeKind.Block => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_BLOCK
        case SyntaxNodeKind.TypeAlias => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_TYPEALIAS
        case SyntaxNodeKind.ClassDecl => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_CLASSDECL
        case SyntaxNodeKind.PropGetterOrSetter => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_PROPGETTERORSETTER
        case SyntaxNodeKind.PropDecl => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_PROPDECL
        case SyntaxNodeKind.StaticInit => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_STATICINIT
        case SyntaxNodeKind.StructDecl => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_STRUCTDECL
        case SyntaxNodeKind.InterfaceDecl => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_INTERFACEDECL
        case SyntaxNodeKind.ExtendDecl => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_EXTENDDECL
        case SyntaxNodeKind.EnumDecl => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_ENUMDECL
        case SyntaxNodeKind.EnumConstructor => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_ENUMCONSTRUCTOR
        case SyntaxNodeKind.MacroDecl => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_MACRODECL
        case SyntaxNodeKind.MacroExpandDecl => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_MACROEXPANDDECL
        case SyntaxNodeKind.MacroExpandParam => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_MACROEXPANDPARAM
        case SyntaxNodeKind.ValuedLiteral => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_VALUEDLITERAL
        case SyntaxNodeKind.UnitLiteral => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_UNITLITERAL
        case SyntaxNodeKind.RuneLiteral => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_RUNELITERAL
        case SyntaxNodeKind.LineStringLiteral => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_LINESTRINGLITERAL
        case SyntaxNodeKind.MultiLineStringLiteral => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_MULTILINESTRINGLITERAL
        case SyntaxNodeKind.MultiLineRawStringLiteral => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_MULTILINERAWSTRINGLITERAL
        case SyntaxNodeKind.ArrayLiteral => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_ARRAYLITERAL
        case SyntaxNodeKind.TupleLiteral => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_TUPLELITERAL
        case SyntaxNodeKind.AssignExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_ASSIGNEXPR
        case SyntaxNodeKind.VArrayExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_VARRAYEXPR
        case SyntaxNodeKind.MemberAccess => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_MEMBERACCESS
        case SyntaxNodeKind.UnaryExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_UNARYEXPR
        case SyntaxNodeKind.BinaryExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_BINARYEXPR
        case SyntaxNodeKind.CallExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_CALLEXPR
        case SyntaxNodeKind.RefExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_REFEXPR
        case SyntaxNodeKind.IsExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_ISEXPR
        case SyntaxNodeKind.AsExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_ASEXPR
        case SyntaxNodeKind.ParenExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_PARENEXPR
        case SyntaxNodeKind.ReturnExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_RETURNEXPR
        case SyntaxNodeKind.IncOrDecExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_INCORDECEXPR
        case SyntaxNodeKind.RangeExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_RANGEEXPR
        case SyntaxNodeKind.TypeConvExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_TYPECONVEXPR
        case SyntaxNodeKind.OptionalExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_OPTIONALEXPR
        case SyntaxNodeKind.BreakExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_BREAKEXPR
        case SyntaxNodeKind.ContinueExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_CONTINUEEXPR
        case SyntaxNodeKind.SubscriptExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_SUBSCRIPTEXPR
        case SyntaxNodeKind.Lambda => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_LAMBDA
        case SyntaxNodeKind.MatchExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_MATCHEXPR
        case SyntaxNodeKind.TryCatch => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_TRYCATCH
        case SyntaxNodeKind.ThrowExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_THROWEXPR
        case SyntaxNodeKind.SynchronizedExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_SYNCHRONIZEDEXPR
        case SyntaxNodeKind.SpawnExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_SPAWNEXPR
        case SyntaxNodeKind.IfExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_IFEXPR
        case SyntaxNodeKind.WhileExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_WHILEEXPR
        case SyntaxNodeKind.DoWhileExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_DOWHILEEXPR
        case SyntaxNodeKind.ForInExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_FORINEXPR
        case SyntaxNodeKind.JumpExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_JUMPEXPR
        case SyntaxNodeKind.LambdaExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_LAMBDAEXPR
        case SyntaxNodeKind.TryExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_TRYEXPR
        case SyntaxNodeKind.InterpolationExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_INTERPOLATIONEXPR
        case SyntaxNodeKind.QuoteTokenExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_QUOTETOKENEXPR
        case SyntaxNodeKind.QuoteExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_QUOTEEXPR
        case SyntaxNodeKind.QuoteInterpolationExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_QUOTEINTERPOLATIONEXPR
        case SyntaxNodeKind.TrailingClosureExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_TRAILINGCLOSUREEXPR
        case SyntaxNodeKind.UnsafeExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_UNSAFEEXPR
        case SyntaxNodeKind.MacroExpandExpr => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_MACROEXPANDEXPR
        case SyntaxNodeKind.ExceptTypePattern => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_EXCEPTTYPEPATTERN
        case SyntaxNodeKind.WildcardPattern => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_WILDCARDPATTERN
        case SyntaxNodeKind.ConstPattern => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_CONSTPATTERN
        case SyntaxNodeKind.VarBindingPattern => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_VARBINDINGPATTERN
        case SyntaxNodeKind.VarOrEnumPattern => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_VARORENUMPATTERN
        case SyntaxNodeKind.TuplePattern => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_TUPLEPATTERN
        case SyntaxNodeKind.TypePattern => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_TYPEPATTERN
        case SyntaxNodeKind.EnumPattern => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_ENUMPATTERN
        case SyntaxNodeKind.Token => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_TOKEN
        case SyntaxNodeKind.DotToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_DOTTOKEN
        case SyntaxNodeKind.CommaToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_COMMATOKEN
        case SyntaxNodeKind.LParenToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_LPARENTOKEN
        case SyntaxNodeKind.RParenToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_RPARENTOKEN
        case SyntaxNodeKind.LSquareToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_LSQUARETOKEN
        case SyntaxNodeKind.RSquareToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_RSQUARETOKEN
        case SyntaxNodeKind.LCurlToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_LCURLTOKEN
        case SyntaxNodeKind.RCurlToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_RCURLTOKEN
        case SyntaxNodeKind.ExpToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_EXPTOKEN
        case SyntaxNodeKind.MulToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_MULTOKEN
        case SyntaxNodeKind.ModToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_MODTOKEN
        case SyntaxNodeKind.DivToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_DIVTOKEN
        case SyntaxNodeKind.AddToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_ADDTOKEN
        case SyntaxNodeKind.SubToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_SUBTOKEN
        case SyntaxNodeKind.IncrToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_INCRTOKEN
        case SyntaxNodeKind.DecrToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_DECRTOKEN
        case SyntaxNodeKind.AndToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_ANDTOKEN
        case SyntaxNodeKind.OrToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_ORTOKEN
        case SyntaxNodeKind.CoalescingToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_COALESCINGTOKEN
        case SyntaxNodeKind.PipelineToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_PIPELINETOKEN
        case SyntaxNodeKind.CompositionToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_COMPOSITIONTOKEN
        case SyntaxNodeKind.NotToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_NOTTOKEN
        case SyntaxNodeKind.BitAndToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_BITANDTOKEN
        case SyntaxNodeKind.BitOrToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_BITORTOKEN
        case SyntaxNodeKind.BitXorToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_BITXORTOKEN
        case SyntaxNodeKind.BitNotToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_BITNOTTOKEN
        case SyntaxNodeKind.LShiftToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_LSHIFTTOKEN
        case SyntaxNodeKind.RShiftToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_RSHIFTTOKEN
        case SyntaxNodeKind.ColonToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_COLONTOKEN
        case SyntaxNodeKind.SemiToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_SEMITOKEN
        case SyntaxNodeKind.AssignToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_ASSIGNTOKEN
        case SyntaxNodeKind.AddAssignToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_ADDASSIGNTOKEN
        case SyntaxNodeKind.SubAssignToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_SUBASSIGNTOKEN
        case SyntaxNodeKind.MulAssignToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_MULASSIGNTOKEN
        case SyntaxNodeKind.ExpAssignToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_EXPASSIGNTOKEN
        case SyntaxNodeKind.DivAssignToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_DIVASSIGNTOKEN
        case SyntaxNodeKind.ModAssignToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_MODASSIGNTOKEN
        case SyntaxNodeKind.AndAssignToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_ANDASSIGNTOKEN
        case SyntaxNodeKind.OrAssignToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_ORASSIGNTOKEN
        case SyntaxNodeKind.BitAndAssignToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_BITANDASSIGNTOKEN
        case SyntaxNodeKind.BitOrAssignToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_BITORASSIGNTOKEN
        case SyntaxNodeKind.BitXorAssignToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_BITXORASSIGNTOKEN
        case SyntaxNodeKind.LShiftAssignToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_LSHIFTASSIGNTOKEN
        case SyntaxNodeKind.RShiftAssignToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_RSHIFTASSIGNTOKEN
        case SyntaxNodeKind.ArrowToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_ARROWTOKEN
        case SyntaxNodeKind.BackArrowToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_BACKARROWTOKEN
        case SyntaxNodeKind.DoubleArrowToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_DOUBLEARROWTOKEN
        case SyntaxNodeKind.RangeOpToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_RANGEOPTOKEN
        case SyntaxNodeKind.ClosedRangeOpToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_CLOSEDRANGEOPTOKEN
        case SyntaxNodeKind.EllipsisToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_ELLIPSISTOKEN
        case SyntaxNodeKind.HashToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_HASHTOKEN
        case SyntaxNodeKind.AtToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_ATTOKEN
        case SyntaxNodeKind.QuestToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_QUESTTOKEN
        case SyntaxNodeKind.LtToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_LTTOKEN
        case SyntaxNodeKind.GtToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_GTTOKEN
        case SyntaxNodeKind.LeToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_LETOKEN
        case SyntaxNodeKind.GeToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_GETOKEN
        case SyntaxNodeKind.IsToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_ISTOKEN
        case SyntaxNodeKind.AsToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_ASTOKEN
        case SyntaxNodeKind.NotEqToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_NOTEQTOKEN
        case SyntaxNodeKind.EqualToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_EQUALTOKEN
        case SyntaxNodeKind.WildcardToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_WILDCARDTOKEN
        case SyntaxNodeKind.Int8Token => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_INT8TOKEN
        case SyntaxNodeKind.Int16Token => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_INT16TOKEN
        case SyntaxNodeKind.Int32Token => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_INT32TOKEN
        case SyntaxNodeKind.Int64Token => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_INT64TOKEN
        case SyntaxNodeKind.IntNativeToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_INTNATIVETOKEN
        case SyntaxNodeKind.UInt8Token => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_UINT8TOKEN
        case SyntaxNodeKind.UInt16Token => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_UINT16TOKEN
        case SyntaxNodeKind.UInt32Token => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_UINT32TOKEN
        case SyntaxNodeKind.UInt64Token => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_UINT64TOKEN
        case SyntaxNodeKind.UIntNativeToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_UINTNATIVETOKEN
        case SyntaxNodeKind.Float16Token => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_FLOAT16TOKEN
        case SyntaxNodeKind.Float32Token => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_FLOAT32TOKEN
        case SyntaxNodeKind.Float64Token => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_FLOAT64TOKEN
        case SyntaxNodeKind.RuneToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_RUNETOKEN
        case SyntaxNodeKind.BooleanToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_BOOLEANTOKEN
        case SyntaxNodeKind.NothingToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_NOTHINGTOKEN
        case SyntaxNodeKind.UnitToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_UNITTOKEN
        case SyntaxNodeKind.StructToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_STRUCTTOKEN
        case SyntaxNodeKind.EnumToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_ENUMTOKEN
        case SyntaxNodeKind.VArrayToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_VARRAYTOKEN
        case SyntaxNodeKind.ThisTypeToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_THISTYPETOKEN
        case SyntaxNodeKind.FeaturesToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_FEATURESTOKEN
        case SyntaxNodeKind.PackageToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_PACKAGETOKEN
        case SyntaxNodeKind.ImportToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_IMPORTTOKEN
        case SyntaxNodeKind.ClassToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_CLASSTOKEN
        case SyntaxNodeKind.InterfaceToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_INTERFACETOKEN
        case SyntaxNodeKind.FuncToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_FUNCTOKEN
        case SyntaxNodeKind.MacroToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_MACROTOKEN
        case SyntaxNodeKind.QuoteToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_QUOTETOKEN
        case SyntaxNodeKind.DollarToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_DOLLARTOKEN
        case SyntaxNodeKind.LetToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_LETTOKEN
        case SyntaxNodeKind.VarToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_VARTOKEN
        case SyntaxNodeKind.ConstToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_CONSTTOKEN
        case SyntaxNodeKind.TypeToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_TYPETOKEN
        case SyntaxNodeKind.InitToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_INITTOKEN
        case SyntaxNodeKind.ThisToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_THISTOKEN
        case SyntaxNodeKind.SuperToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_SUPERTOKEN
        case SyntaxNodeKind.IfToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_IFTOKEN
        case SyntaxNodeKind.ElseToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_ELSETOKEN
        case SyntaxNodeKind.CaseToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_CASETOKEN
        case SyntaxNodeKind.TryToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_TRYTOKEN
        case SyntaxNodeKind.CatchToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_CATCHTOKEN
        case SyntaxNodeKind.FinallyToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_FINALLYTOKEN
        case SyntaxNodeKind.ForToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_FORTOKEN
        case SyntaxNodeKind.DoToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_DOTOKEN
        case SyntaxNodeKind.WhileToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_WHILETOKEN
        case SyntaxNodeKind.ThrowToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_THROWTOKEN
        case SyntaxNodeKind.ReturnToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_RETURNTOKEN
        case SyntaxNodeKind.ContinueToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_CONTINUETOKEN
        case SyntaxNodeKind.BreakToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_BREAKTOKEN
        case SyntaxNodeKind.InToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_INTOKEN
        case SyntaxNodeKind.NotInToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_NOTINTOKEN
        case SyntaxNodeKind.MatchToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_MATCHTOKEN
        case SyntaxNodeKind.WhereToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_WHERETOKEN
        case SyntaxNodeKind.ExtendToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_EXTENDTOKEN
        case SyntaxNodeKind.WithToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_WITHTOKEN
        case SyntaxNodeKind.PropToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_PROPTOKEN
        case SyntaxNodeKind.GetToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_GETTOKEN
        case SyntaxNodeKind.SetToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_SETTOKEN
        case SyntaxNodeKind.StaticToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_STATICTOKEN
        case SyntaxNodeKind.PublicToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_PUBLICTOKEN
        case SyntaxNodeKind.PrivateToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_PRIVATETOKEN
        case SyntaxNodeKind.InternalToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_INTERNALTOKEN
        case SyntaxNodeKind.ProtectedToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_PROTECTEDTOKEN
        case SyntaxNodeKind.OverrideToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_OVERRIDETOKEN
        case SyntaxNodeKind.RedefToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_REDEFTOKEN
        case SyntaxNodeKind.AbstractToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_ABSTRACTTOKEN
        case SyntaxNodeKind.SealedToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_SEALEDTOKEN
        case SyntaxNodeKind.OpenToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_OPENTOKEN
        case SyntaxNodeKind.ForeignToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_FOREIGNTOKEN
        case SyntaxNodeKind.InoutToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_INOUTTOKEN
        case SyntaxNodeKind.MutToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_MUTTOKEN
        case SyntaxNodeKind.UnsafeToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_UNSAFETOKEN
        case SyntaxNodeKind.OperatorToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_OPERATORTOKEN
        case SyntaxNodeKind.SpawnToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_SPAWNTOKEN
        case SyntaxNodeKind.SynchronizedToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_SYNCHRONIZEDTOKEN
        case SyntaxNodeKind.UpperBoundToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_UPPERBOUNDTOKEN
        case SyntaxNodeKind.MainToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_MAINTOKEN
        case SyntaxNodeKind.IdentToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_IDENTTOKEN
        case SyntaxNodeKind.PackageIdentifierToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_PACKAGEIDENTIFIERTOKEN
        case SyntaxNodeKind.IntegerLiteralToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_INTEGERLITERALTOKEN
        case SyntaxNodeKind.FloatLiteralToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_FLOATLITERALTOKEN
        case SyntaxNodeKind.CommentToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_COMMENTTOKEN
        case SyntaxNodeKind.NewlineToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_NEWLINETOKEN
        case SyntaxNodeKind.EndToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_ENDTOKEN
        case SyntaxNodeKind.SentinelToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_SENTINELTOKEN
        case SyntaxNodeKind.RunePrefixToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_RUNEPREFIXTOKEN
        case SyntaxNodeKind.DoubleQuoteToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_DOUBLEQUOTETOKEN
        case SyntaxNodeKind.SingleQuoteToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_SINGLEQUOTETOKEN
        case SyntaxNodeKind.JStringLiteralToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_JSTRINGLITERALTOKEN
        case SyntaxNodeKind.MultilineStringToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_MULTILINESTRINGTOKEN
        case SyntaxNodeKind.MultilineRawStringToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_MULTILINERAWSTRINGTOKEN
        case SyntaxNodeKind.BooleanLiteralToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_BOOLEANLITERALTOKEN
        case SyntaxNodeKind.DollarIdentifierToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_DOLLARIDENTIFIERTOKEN
        case SyntaxNodeKind.AnnotationToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_ANNOTATIONTOKEN
        case SyntaxNodeKind.AtExclToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_ATEXCLTOKEN
        case SyntaxNodeKind.CommonToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_COMMONTOKEN
        
        case SyntaxNodeKind.HandleToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_HANDLETOKEN
        case SyntaxNodeKind.PerformToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_PERFORMTOKEN
        case SyntaxNodeKind.ResumeToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_RESUMETOKEN
        case SyntaxNodeKind.ThrowingToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_THROWINGTOKEN
        case SyntaxNodeKind.TripleSingleQuoteToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_TRIPLESINGLEQUOTETOKEN
        case SyntaxNodeKind.TripleDoubleQuoteToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_TRIPLEDOUBLEQUOTETOKEN
        case SyntaxNodeKind.SpaceToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_SPACETOKEN
        case SyntaxNodeKind.StringLiteralToken => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_STRINGLITERALTOKEN
        case SyntaxNodeKind.Invalid => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_INVALID
        case _ => return SyntaxNodeFormat_NodeImplKind.NodeImplKind_INVALID
    }
}