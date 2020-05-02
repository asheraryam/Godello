class_name ListModel extends Model

var id : String
var title : String
var cards : Array

func _init(_id : String, _title : String, _cards : Array = []).(ModelTypes.LIST):
	id = _id
	title = _title
	cards = _cards
