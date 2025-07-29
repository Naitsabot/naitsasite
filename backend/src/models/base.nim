import std/[times, json, strutils]
import uuid4


type
    BaseModel* = ref object of RootObj
        id*: string
        createdAt*: DateTime
        updatedAt*: DateTime


proc newBaseModel*(): BaseModel =
    result = BaseModel(
        id: $uuid4(),
        createdAt: now(),
        updatedAt: now()
    )


proc touch*(model: BaseModel) =
    model.updatedAt = now()


proc toJsonBase*(model: BaseModel): JsonNode =
    result = %*{
        "id": model.id,
        "created_at": model.createdAt.format("yyyy-MM-dd'T'HH:mm:ss'Z'"),
        "updated_at": model.updatedAt.format("yyyy-MM-dd'T'HH:mm:ss'Z'")
    }


proc fromJsonBase*(model: BaseModel, node: JsonNode) =
    if node.hasKey("id"):
        model.id = node["id"].getStr()
    
    if node.hasKey("created_at"):
        try:
            model.createdAt = node["created_at"].getStr().parse("yyyy-MM-dd'T'HH:mm:ss'Z'")
        except:
            model.createdAt = now()
    
    if node.hasKey("updated_at"):
        try:
            model.updatedAt = node["updated_at"].getStr().parse("yyyy-MM-dd'T'HH:mm:ss'Z'")
        except:
            model.updatedAt = now()


proc isValidId*(id: string): bool =
    ## Check if ID looks like a valid UUID
    result = id.len > 0 and '-' in id


proc isRecent*(model: BaseModel, minutes: int = 5): bool =
    ## Check if model was created/updated recently
    let timeDiff = now() - model.updatedAt
    result = timeDiff.inMinutes <= minutes
