-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local internal = LGB.internal

--[[ doc.lua begin ]] --

--- Registers a handler under a unique name. A handler in this context is a library or addon that uses one or more protocols or custom events for communication.
--- @param addonName string The name of the addon or library that is registering the handler.
--- @param handlerName? string An optional short name of the handler to register, which can be used in addition to the addon name to get the handler api.
--- @return Handler handler An object with methods to declare protocols and custom events with and to modify various aspects of the handler, or nil if the registration failed.
--- @see LibGroupBroadcast.GetHandlerApi
function LGB:RegisterHandler(addonName, handlerName)
    return internal.handlerManager:RegisterHandler(addonName, handlerName)
end

--- Returns a handler's api by its unique name, if it is public.
--- @param handlerName string The name of the handler to get.
--- @return table handler The handler api table that was registered with the given handler name or nil if no api was provided.
--- @see LibGroupBroadcast.RegisterHandler
function LGB:GetHandlerApi(handlerName)
    return internal.handlerManager:GetHandlerApi(handlerName)
end

--- Registers a callback function to be called when a custom event is received.
--- @param eventName string The custom event name to register for.
--- @param callback fun(unitTag: string) The callback function to call when the custom event is received. Receives the unitTag of the sender as an argument.
--- @return boolean success True if the callback was successfully registered, false otherwise.
function LGB:RegisterForCustomEvent(eventName, callback)
    return internal.protocolManager:RegisterForCustomEvent(eventName, callback)
end

--- Unregisters a callback function from a custom event.
--- @param eventName string The custom event name to unregister from.
--- @param callback fun(unitTag: string) The callback function to unregister. Has to be the same instance as the one registered.
--- @return boolean success True if the callback was successfully unregistered, false otherwise.
function LGB:UnregisterForCustomEvent(eventName, callback)
    return internal.protocolManager:UnregisterForCustomEvent(eventName, callback)
end

--- Creates and returns an ArrayField, which can be used to send the passed field multiple times.
--- Internally this will use a NumericField to store the length of the array and then serialize the values using the passed field.
--- By default the array can have up to 255 elements, but this can be changed using the options table.
--- @param valueField FieldBase The field that should be used for the values in the array.
--- @param options? ArrayFieldOptions The options table to use for the field.
--- @return ArrayField field The created ArrayField instance.
--- @see ArrayField
function LGB.CreateArrayField(valueField, options)
    return internal.class.ArrayField:New(valueField, options)
end

--- Creates and returns an instance of the EnumField class.
--- @param label string The label of the field.
--- @param valueTable any[] The array containing the possible values for the field.
--- @param options? EnumFieldOptions The options table to use for the field.
--- @return EnumField field The created EnumField instance.
--- @see EnumField
function LGB.CreateEnumField(label, valueTable, options)
    return internal.class.EnumField:New(label, valueTable, options)
end

--- Creates and returns an instance of the FlagField class.
--- @param label string The label of the field.
--- @param options? FlagFieldOptions The options table to use for the field.
--- @return FlagField field The created FlagField instance.
--- @see FlagField
function LGB.CreateFlagField(label, options)
    return internal.class.FlagField:New(label, options)
end

--- Creates and returns an instance of the NumericField class.
--- @param label string The label of the field.
--- @param options? NumericFieldOptions The options table to use for the field.
--- @return NumericField field The created NumericField instance.
--- @see NumericField
function LGB.CreateNumericField(label, options)
    return internal.class.NumericField:New(label, options)
end

--- Creates and returns an instance of the OptionalField class.
--- @param valueField FieldBase The field that should be made optional.
--- @return OptionalField field The created OptionalField instance.
--- @see OptionalField
function LGB.CreateOptionalField(valueField)
    return internal.class.OptionalField:New(valueField)
end

--- Creates and returns an instance of the PercentageField class.
--- @param label string The label of the field.
--- @param options? PercentageFieldOptions The options table to use for the field.
--- @return PercentageField field The created PercentageField instance.
--- @see PercentageField
function LGB.CreatePercentageField(label, options)
    return internal.class.PercentageField:New(label, options)
end

--- Creates and returns an instance of the ReservedField class.
--- @param label string The label of the field.
--- @param numBits number The number of bits to reserve.
--- @return ReservedField field The created ReservedField instance.
--- @see ReservedField
function LGB.CreateReservedField(label, numBits)
    return internal.class.ReservedField:New(label, numBits)
end

--- Creates and returns an instance of the StringField class.
--- @param label string The label of the field.
--- @param options? StringFieldOptions The options table to use for the field.
--- @return StringField field The created StringField instance.
--- @see StringField
function LGB.CreateStringField(label, options)
    return internal.class.StringField:New(label, options)
end

--- Creates and returns an instance of the TableField class.
--- @param label string The label of the field.
--- @param valueFields FieldBase[] A list of fields contained in the table.
--- @param options? TableFieldOptions The options table to use for the field.
--- @return TableField field The created TableField instance.
--- @see TableField
function LGB.CreateTableField(label, valueFields, options)
    return internal.class.TableField:New(label, valueFields, options)
end

--- Creates and returns an instance of the VariantField class.
--- @param variants FieldBase[] A list of fields that can be used as variants.
--- @param options? VariantFieldOptions The options table to use for the field.
--- @return VariantField field The created VariantField instance.
--- @see VariantField
function LGB.CreateVariantField(variants, options)
    return internal.class.VariantField:New(variants, options)
end

--- Creates a subclass of the FieldBase class. Can be used to create custom field types.
--- @generic T : FieldBase
--- @return T subclass The created FieldBase subclass.
--- @see FieldBase
function LGB.CreateFieldBaseSubclass()
    return internal.class.FieldBase:Subclass()
end

--- Creates a new separate instance of the LibGroupBroadcast library for use in Taneth tests.
---
--- The returned table has the same API as the global LibGroupBroadcast table, but is not connected to the global state.
--- It also contains references to some internal objects that are not normally exposed and uses an instance of MockGameApiWrapper.
---
--- @param createWithoutSaveData? boolean If true, the mock instance will behave like before EVENT_ADD_ON_LOADED was fired and not have any save data.
--- @return LibGroupBroadcastMockInstance instance A new instance of the library for use in tests.
--- @see LibGroupBroadcastInternal.SetupMockInstance
function LGB.SetupMockInstance(createWithoutSaveData)
    return internal.SetupMockInstance(createWithoutSaveData)
end

--[[ doc.lua end ]] --

LGB:Initialize()
