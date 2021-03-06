import Foundation



/// `JSONHelper` is a bag of functions for converting to and from JSON representations. It's a *very* thin wrapper around `JSONSerialization`.
public enum JSONHelper {
  //MARK: - JSON from Data
  /**
   Decodes `Data` representation of a JSON object into a `JSONObject`.
   
   * parameter data: The bytes of a string representing a JSON object, encoded as UTF-8.
   * throws: Standard `Error` if `data` is unreadable or not UTF-8. `JSONError.malformed` if `data` does not represent JSON and `JSONError.unexpectedType` if `data` represents something other than a JSON object.
   * returns: A `JSONObject` representation of `data`.
   */
  public static func jsonObject(from data: Data) throws -> JSONObject {
    return try anyJSON(from: data).objectValue()
  }
  
  
  /**
   Decodes `Data` representation of a JSON array into a `JSONArray`.
   
   * parameter data: The bytes of a string representing a JSON array, encoded as UTF-8.
   * throws: Standard `Error` if `data` is unreadable or not UTF-8. `JSONError.malformed` if `data` cannot be parsed as JSON and `JSONError.unexpectedType` if `data` represents something other than a JSON array.
   * returns: A `JSONArray` representation of `data`.
   */
  public static func jsonArray(from data: Data) throws -> JSONArray {
    return try anyJSON(from: data).arrayValue()
  }
  
  
  public static func jsonString(from data: Data) throws -> String {
    return try anyJSON(from: data).stringValue()
  }
  
  
  public static func jsonNumber(from data: Data) throws -> NSNumber {
    return try anyJSON(from: data).numberValue()
  }
  
  
  public static func jsonBool(from data: Data) throws -> Bool {
    return try anyJSON(from: data).boolValue()
  }
  
  
  public static func jsonIsNull(from data: Data) throws -> Bool {
    return try anyJSON(from: data).isNull
  }
  
  
  public static func anyJSON(from data: Data) throws -> AnyJSON {
    do {
      return try AnyJSON(JSONSerialization.jsonObject(with: data, options: .allowFragments))
      
    } catch let e as NSError {
      switch (e.domain, e.code) {
      case (NSCocoaErrorDomain, 3840):
        throw JSONError.malformed
      default:
        throw e
      }
    }
  }
  
  
  //MARK: - JSON from String
  /**
   Parses `String` representation of a JSON object into a `JSONObject`.
   
   * parameter string: A string representing a JSON object.
   * throws: `JSONError.malformed` if `string` cannot be parsed as JSON and `JSONError.unexpectedType` if `string` represents something other than a JSON object.
   * returns: A `JSONObject` representation of `string`.
   */
  public static func jsonObject(from string: String) throws -> JSONObject {
    return try anyJSON(from: Helper.data(from: string)).objectValue()
  }
  
  
  /**
   Parses `String` representation of a JSON array into a `JSONArray`.
   
   * parameter string: A string representing a JSON object.
   * throws: `JSONError.malformed` if `string` cannot be parsed as JSON and `JSONError.unexpectedType` if `string` represents something other than a JSON array.
   * returns: A `JSONArray` representation of `string`.
   */
  public static func jsonArray(from string: String) throws -> JSONArray {
    return try anyJSON(from: Helper.data(from: string)).arrayValue()
  }
  
  
  public static func jsonString(from string: String) throws -> String {
    return try anyJSON(from: Helper.data(from: string)).stringValue()
  }
  
  
  public static func jsonNumber(from string: String) throws -> NSNumber {
    return try anyJSON(from: Helper.data(from: string)).numberValue()
  }
  
  
  public static func jsonBool(from string: String) throws -> Bool {
    return try anyJSON(from: Helper.data(from: string)).boolValue()
  }
  
  
  public static func jsonIsNull(from string: String) throws -> Bool {
    return try anyJSON(from: Helper.data(from: string)).isNull
  }
  
  
  public static func anyJSON(from string: String) throws -> AnyJSON {
    return try anyJSON(from: Helper.data(from: string))
  }
  
  
  //MARK: - JSON from file
  /**
   Decodes contents of UTF-8 file into a `JSONObject`.
   
   * parameter name: Name of the file in the given `bundle` to decode.
   * parameter extension: Extension to use with `name`. Defaults to "json".
   * parameter bundle: Bundle to search for file named `name`. Defaults to `Bundle.main`.
   * throws: `FileError` if file is not found or unreadable. `JSONError` if file cannot be parsed as a JSON object.
   * returns: A `JSONObject` representation of data in file.
   */
  public static func jsonObject(fromFileNamed name: String, extension: String = "json", bundle: Bundle = Bundle.main) throws -> JSONObject {
    return try anyJSON(fromFileNamed: name, extension: `extension`, bundle: bundle).objectValue()
  }

  
  /**
   Decodes contents of UTF-8 file into a into a `JSONArray`.
   
   * parameter name: Name of the file in the given `bundle` to decode.
   * parameter extension: Extension to use with `name`. Defaults to "json".
   * parameter bundle: Bundle to search for file named `name`. Defaults to `Bundle.main`.
   * throws: `FileError` if file is not found or unreadable. `JSONError` if file cannot be parsed as a JSON array.
   * returns: A `JSONArray` representation of data in file.
   */
  public static func jsonArray(fromFileNamed name: String, extension: String = "json", bundle: Bundle = Bundle.main) throws -> JSONArray {
    return try anyJSON(fromFileNamed: name, extension: `extension`, bundle: bundle).arrayValue()
  }

  
  /**
   Decodes contents of UTF-8 as JSON.
   
   * note: While this will parse files a file as a string, a numbers or even just `null`, there are probably more efficient ways of doing this than going through a JSON deserializer.
   
   * seealso: `jsonObject(fromFileNamed:extension:bundle)` and `jsonArray(fromFileNamed:extension:bundle)`
   
   * parameter name: Name of the file in the given `bundle` to decode.
   * parameter extension: Extension to use with `name`. Defaults to "json".
   * parameter bundle: Bundle to search for file named `name`. Defaults to `Bundle.main`.
   * throws: `FileError` if file is not found or unreadable. `JSONError` if file cannot be parsed as JSON.
   * returns: An `AnyJSON` representation of data in file.
   */
  public static func anyJSON(fromFileNamed name: String, extension: String = "json", bundle: Bundle = Bundle.main) throws -> AnyJSON {
    guard let url = bundle.url(forResource: name, withExtension: `extension`) else {
      throw FileError.fileNotFound(name + "." + `extension`)
    }
    guard let data = try? Data(contentsOf: url) else {
      throw FileError.cannotRead(url)
    }
    return try anyJSON(from: data)
  }
  
  
  //MARK: - Data from JSON
  /**
   Serializes a `JSONObject` into `Data`.
   
   * parameter jsonObject: The JSONObject to serialize.
   * throws: `JSONError.invalidType` if `JSONObject` isn't a valid JSON object.
   * returns: The bytes of a string representing a JSON object, encoded as UTF-8.
   */
  public static func data(from jsonObject: JSONObject) throws -> Data {
    return try Helper.dataFromAny(jsonObject)
  }
  
  
  /**
   Serializes a `ValidJSONObject` into `Data`. Because it takes a `ValidJSONObject`, it doesn't throw.
   
   * parameter jsonObject: The `ValidJSONObject` to serialize.
   * returns: The bytes of a string representing a JSON object, encoded as UTF-8.
   */
  public static func data(from jsonObject: ValidJSONObject) -> Data {
    return try! Helper.dataFromAny(jsonObject.value)
  }
  
  
  /**
   Serializes a `JSONArray` into `Data`.
   
   * parameter jsonArray: The JSONArray to serialize.
   * throws: `JSONError.invalidType` if `JSONArray` isn't an array of JSON-safe values.
   * returns: The bytes of a string representing a JSON array, encoded as UTF-8.
   */
  public static func data(from jsonArray: JSONArray) throws -> Data {
    return try Helper.dataFromAny(jsonArray)
  }
  
  
  /**
   Serializes a `ValidJSONArray` into `Data`. Because it takes a `ValidJSONArray`, it doesn't throw.
   
   * parameter jsonArray: The `ValidJSONArray` to serialize.
   * returns: The bytes of a string representing a JSON array, encoded as UTF-8.
   */
  public static func data(from jsonArray: ValidJSONArray)-> Data {
    return try! Helper.dataFromAny(jsonArray.value)
  }
  
  
  //MARK: - String from JSON
  /**
   Serializes a `JSONObject` into a `String`.
   
   * parameter jsonObject: The JSONObject to serialize.
   * throws: `JSONError.invalidType` if `JSONObject` isn't a valid JSON object. `StringError.encoding` will be thrown if the serialized JSON can't be represented by a UTF-8 string, but that should be impossible.
   * returns: A string representing a JSON object, encoded as UTF-8.
   */
  public static func string(from json: JSONObject) throws -> String {
    return try Helper.string(from: data(from: json))
  }
  
  
  /**
   Serializes a `ValidJSONObject` into a `String`. Because it takes a `ValidJSONObject` it doesn't throw.
   
   * parameter jsonObject: The `ValidJSONObject` to serialize.
   * returns: A string representing a JSON object, encoded as UTF-8.
   */
  public static func string(from json: ValidJSONObject) -> String {
    return try! Helper.string(from: data(from: json))
  }
  
  
  /**
   Serializes a `JSONArray` into a `String`.
   
   * parameter jsonArray: The JSONArray to serialize.
   * throws: `JSONError.invalidType` if `JSONArray` isn't an array of JSON-safe values. `StringError.encoding` will be thrown if the serialized JSON can't be represented by a UTF-8 string, but that should be impossible.
   * returns: A string representing a JSON array, encoded as UTF-8.
   */
  public static func string(from json: JSONArray) throws -> String {
    return try Helper.string(from: data(from: json))
  }
  
  
  /**
   Serializes a `ValidJSONArray` into a `String`. Because it takes a `ValidJSONArray`, it doesn't throw.
   
   * parameter jsonArray: The `ValidJSONArray` to serialize.
   * returns: A string representing a JSON array, encoded as UTF-8.
   */
  public static func string(from json: ValidJSONArray) -> String {
    return try! Helper.string(from: data(from: json))
  }
  
  
  //MARK: - Validation
  /**
   Validates whether the given `String` is valid JSON text.
   
   * note: While this could be used to (redundantly?) validate a string-type JSON value, it is more usefully applied to JSON serialized as a string.
   
   * parameter string: The JSON text to validate.
   * returns: `true` if the string represents valid JSON. Otherwise: `false`.
   */
  public static func isValid(_ jsonText: String) -> Bool {
    return isValid(Helper.data(from: jsonText))
  }
  
  
  /**
   Validates whether the given bytes represent well-formed JSON text.
   
   * parameter data: The bytes to validate.
   * returns: `true` if `data` represents the bytes of a UTF-8 encoded string, and said string depicts valid JSON. Otherwise: `false`.
   */
  public static func isValid(_ data: Data) -> Bool {
    if let _ = try? anyJSON(from: data) {
      return true
    }
    return false
  }
  
  
  /**
   Validates whether the given `JSONObject` contains only valid JSON types.
   
   * parameter jsonObject: The object to validate.
   * returns: `true` if `jsonObject` contains only types representable in JSON. Otherwise: `false`.
   */
  public static func isValid(_ jsonObject: JSONObject) -> Bool {
    if let _ = try? Helper.dataFromAny(jsonObject) {
      return true
    }
    return false
  }
  
  
  /**
   Validates whether the given `JSONArray` contains only valid JSON types.
   
   * parameter jsonArray: The array to validate.
   * returns: `true` if `jsonArray` contains only types representable in JSON. Otherwise: `false`.
   */
  public static func isValid(_ jsonArray: JSONArray) -> Bool {
    if let _ = try? Helper.dataFromAny(jsonArray) {
      return true
    }
    return false
  }
  
  
  /**
   Validates whether the given `String` is well-formed JSON text, throwing if it's not.
   
   * note: While this could be used to (redundantly?) validate a string-type JSON value, it is more usefully applied to JSON serialized as a string.
   
   * parameter string: The string to validate.
   * throws: `JSONError.malformed` if `string` cannot be parsed as JSON.
   */
  public static func validate(_ string: String) throws {
    try validate(Helper.data(from: string))
  }
  
  
  /**
   Validates whether the given bytes represent well-formed JSON text, throwing if they do not.
   
   * parameter data: The bytes to validate.
   * throws: Standard `Error` if `data` is unreadable or not UTF-8. `JSONError.malformed` if `data` cannot be parsed as JSON.
   */
  public static func validate(_ data: Data) throws {
    _ = try anyJSON(from: data)
  }
  
  
  /**
   Validates whether the given `JSONObject` contains only valid JSON types, throwing if it does not.
   
   * parameter jsonObject: The object to validate.
   * throws: `JSONError.invalid` if `JSONObject` isn't a valid JSON object.
   */
  public static func validate(_ jsonObject: JSONObject) throws {
    _ = try Helper.dataFromAny(jsonObject)
  }
  
  
  /**
   Validates whether the given `JSONArray` contains only valid JSON types, throwing if it does not.
   
   * parameter jsonArray: The array to validate.
   * throws: `JSONError.invalid` if `JSONArray` isn't an array of JSON-safe values.
   */
  public static func validate(_ jsonArray: JSONArray) throws {
    _ = try Helper.dataFromAny(jsonArray)
  }
}



private enum Helper  {
  static func string(from data: Data) throws -> String {
    guard let string = String(data: data, encoding: .utf8) else {
      throw StringError.encoding
    }
    return string
  }
  
  
  static func data(from string: String) -> Data {
    // This cannot be `nil` when `allowLossyConversion` is `true`. So we force-unwrap.
    // Aside: it should be impossible for any `String` to fail even a lossless conversion to UTF-8 (there are currently no characters unrepresentable in UTF-8), but we're being pedantic.
    return string.data(using: .utf8, allowLossyConversion: true)!
  }
  
  
  static func dataFromAny(_ any: Any) throws -> Data {
    guard JSONSerialization.isValidJSONObject(any) else {
      throw JSONError.invalidType
    }
    return try JSONSerialization.data(withJSONObject: any, options: [])
  }
}

