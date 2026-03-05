# Conversion Between JsonValue and DataModel

The following demonstrates the conversion between JSON strings and custom types. In this example, the `Person` type implements the `Serializable` interface, followed by conversions from JSON strings to custom types and from custom types to JSON strings.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::serialization.serialization.*
import cangjie_stdx::encoding.json.*

class Person <: Serializable<Person> {
    var name: String = ""
    var age: Int64 = 0
    var loc: Option<Location> = Option<Location>.None

    public func serialize(): DataModel {
        return DataModelStruct()
            .add(field<String>("name", name))
            .add(field<Int64>("age", age))
            .add(field<Option<Location>>("loc", loc))
    }

    public static func deserialize(dm: DataModel): Person {
        var dms = match (dm) {
            case data: DataModelStruct => data
            case _ => throw Exception("this data is not DataModelStruct")
        }
        var result = Person()
        result.name = String.deserialize(dms.get("name"))
        result.age = Int64.deserialize(dms.get("age"))
        result.loc = Option<Location>.deserialize(dms.get("loc"))
        return result
    }
}

class Location <: Serializable<Location> {
    var country: String = ""
    var province: String = ""

    public func serialize(): DataModel {
        return DataModelStruct().add(field<String>("country", country)).add(field<String>("province", province))
    }

    public static func deserialize(dm: DataModel): Location {
        var dms = match (dm) {
            case data: DataModelStruct => data
            case _ => throw Exception("this data is not DataModelStruct")
        }
        var result = Location()
        result.country = String.deserialize(dms.get("country"))
        result.province = String.deserialize(dms.get("province"))
        return result
    }
}

main() {
    var js = ##"{
    "name": "A",
    "age": 30,
    "loc": {
        "country": "China",
        "province": "Beijing"
    }
}"##

    /* Convert from JSON string to custom type */
    var jv = JsonValue.fromStr(js)
    var dm = DataModel.fromJson(jv)
    var A = Person.deserialize(dm)
    println("name == ${A.name}")
    println("age == ${A.age}")
    println("country == ${A.loc.getOrThrow().country}")
    println("province == ${A.loc.getOrThrow().province}")
    println("====================")

    /* Convert from custom type to JSON string */
    dm = A.serialize()
    var jo = dm.toJson().asObject()
    println(jo.toJsonString())
}
```

Execution result:

```text
name == A
age == 30
country == China
province == Beijing
====================
{
  "name": "A",
  "age": 30,
  "loc": {
    "country": "China",
    "province": "Beijing"
  }
}
```