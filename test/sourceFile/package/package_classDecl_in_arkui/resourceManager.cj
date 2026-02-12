package testPackage

import std.binary.*
import std.math.*
import std.collection.*

// public type ResourceId = Int32

class ResourceInfo {
    public var resource: Any
    public var holdersCount: Int32
    init(resource: Any, holdersCount: Int32 ) {
        this.resource = resource
        this.holdersCount = holdersCount
    }
}

public class ResourceHolder {
    private static var nextResourceId: Int32 = 100
    private var resources: HashMap<Int32, ResourceInfo> = HashMap<Int32, ResourceInfo>()
    private static var _instance: ?ResourceHolder = Option.None
    public static func instance(): ResourceHolder {
        ResourceHolder._instance = match (ResourceHolder._instance) {
            case Some(resourceHolder) => resourceHolder
            case _ => ResourceHolder()
        }
        if (let Some(rh) <- ResourceHolder._instance) {
            return rh
        } else {
            throw Exception()
        }
    }
    public func hold(resourceId: Int32) {
        match(this.resources.get(resourceId)) {
            case Some(resource) => resource.holdersCount++
            case _ => throw Exception("Resource ${resourceId} does not exists, can not hold")
        }
    }

    public func release(resourceId: Int32) {
        let resource = match (this.resources.get(resourceId)) {
            case Some(resource) => resource
            case _ => throw Exception("Resource ${resourceId} does not exists, can not hold")
        }
        resource.holdersCount--
        if (resource.holdersCount <= 0) {
            this.resources.remove(resourceId)
        }
    }

    public func registerAndHold(resource: Any): Int32 {
        ResourceHolder.nextResourceId += 1
        let resourceId = ResourceHolder.nextResourceId
        this.resources.add(resourceId, ResourceInfo(resource, resourceId))
        return resourceId
    }

    public func get(resourceId: Int32): Any {
        match(this.resources.get(resourceId)) {
            case Some(resource) => return resource.resource
            case _ => throw Exception("Resource ${resourceId} does not exists")
        }
    }
}
