-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end
--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local class = LGB.internal.class
local Handler = class.Handler

Taneth("LibGroupBroadcast", function()
    describe("PublicApi", function()
        it("should not have access to the internal table", function()
            assert.is_nil(LGB.internal)
        end)

        it("should have a function to setup a mock instance of the library", function()
            assert.equals("function", type(LGB.SetupMockInstance))
            local instance = LGB.SetupMockInstance()
            assert.equals("table", type(instance))
        end)

        it("should have functions to register and get a handler's api", function()
            assert.equals("function", type(LGB.RegisterHandler))
            assert.equals("function", type(LGB.GetHandlerApi))
            local instance = LGB.SetupMockInstance()
            local handlerApi = {}
            local handler = instance:RegisterHandler("test")
            handler:SetApi(handlerApi)
            assert.is_true(ZO_Object.IsInstanceOf(handler, Handler))
            assert.equals(handlerApi, instance:GetHandlerApi("test"))
        end)

        it("should have a way to declare and register for a custom event", function()
            assert.equals("function", type(LGB.RegisterForCustomEvent))
            assert.equals("function", type(LGB.UnregisterForCustomEvent))
            local instance = LGB.SetupMockInstance()
            local handler = instance:RegisterHandler("test")
            local SendEvent = handler:DeclareCustomEvent(0, "test")
            assert.is_not_nil(SendEvent)
            assert.is_true(instance:RegisterForCustomEvent("test", function() end))
            assert.is_true(instance:UnregisterForCustomEvent("test", function() end))
        end)

        it("should have a function to declare a protocol", function()
            local instance = LGB.SetupMockInstance()
            local handler = instance:RegisterHandler("test")
            local protocol = handler:DeclareProtocol(0, "test")
            assert.is_not_nil(protocol)
        end)

        it("should have a function to create an ArrayField", function()
            assert.equals("function", type(LGB.CreateArrayField))
            local instance = LGB.SetupMockInstance()
            local field = instance.CreateArrayField(instance.CreateFlagField("test"))
            assert.is_true(ZO_Object.IsInstanceOf(field, class.ArrayField))
        end)

        it("should have a function to create an EnumField", function()
            assert.equals("function", type(LGB.CreateEnumField))
            local instance = LGB.SetupMockInstance()
            local field = instance.CreateEnumField("test", { "test" })
            assert.is_true(ZO_Object.IsInstanceOf(field, class.EnumField))
        end)

        it("should have a function to create a FlagField", function()
            assert.equals("function", type(LGB.CreateFlagField))
            local instance = LGB.SetupMockInstance()
            local field = instance.CreateFlagField("test")
            assert.is_true(ZO_Object.IsInstanceOf(field, class.FlagField))
        end)

        it("should have a function to create a NumericField", function()
            assert.equals("function", type(LGB.CreateNumericField))
            local instance = LGB.SetupMockInstance()
            local field = instance.CreateNumericField("test")
            assert.is_true(ZO_Object.IsInstanceOf(field, class.NumericField))
        end)

        it("should have a function to create an OptionalField", function()
            assert.equals("function", type(LGB.CreateOptionalField))
            local instance = LGB.SetupMockInstance()
            local field = instance.CreateOptionalField(instance.CreateFlagField("test"))
            assert.is_true(ZO_Object.IsInstanceOf(field, class.OptionalField))
        end)

        it("should have a function to create a PercentageField", function()
            assert.equals("function", type(LGB.CreatePercentageField))
            local instance = LGB.SetupMockInstance()
            local field = instance.CreatePercentageField("test")
            assert.is_true(ZO_Object.IsInstanceOf(field, class.PercentageField))
        end)

        it("should have a function to create a ReservedField", function()
            assert.equals("function", type(LGB.CreateReservedField))
            local instance = LGB.SetupMockInstance()
            local field = instance.CreateReservedField()
            assert.is_true(ZO_Object.IsInstanceOf(field, class.ReservedField))
        end)

        it("should have a function to create a StringField", function()
            assert.equals("function", type(LGB.CreateStringField))
            local instance = LGB.SetupMockInstance()
            local field = instance.CreateStringField("test")
            assert.is_true(ZO_Object.IsInstanceOf(field, class.StringField))
        end)

        it("should have a function to create a TableField", function()
            assert.equals("function", type(LGB.CreateTableField))
            local instance = LGB.SetupMockInstance()
            local field = instance.CreateTableField("test", { instance.CreateFlagField("test") })
            assert.is_true(ZO_Object.IsInstanceOf(field, class.TableField))
        end)

        it("should have a function to create a VariantField", function()
            assert.equals("function", type(LGB.CreateVariantField))
            local instance = LGB.SetupMockInstance()
            local field = instance.CreateVariantField("test", { instance.CreateFlagField("test") })
            assert.is_true(ZO_Object.IsInstanceOf(field, class.VariantField))
        end)

        it("should have a function to create a subclass of FieldBase", function()
            assert.equals("function", type(LGB.CreateFieldBaseSubclass))
            local instance = LGB.SetupMockInstance()
            local MyField = instance.CreateFieldBaseSubclass()
            local field = MyField:New("test")
            assert.is_true(ZO_Object.IsInstanceOf(field, class.FieldBase))
        end)

        it.async("it should be able to send multiple messages", function(done)
            local instance = LGB.SetupMockInstance()

            local received = 0
            local function OnReceive()
                received = received + 1
                if received == 2 then done() end
            end

            local handler = instance:RegisterHandler("test")
            local protocol1 = handler:DeclareProtocol(0, "test1")
            protocol1:AddField(instance.CreateFlagField("test"))
            protocol1:OnData(OnReceive)
            protocol1:Finalize()

            local protocol2 = handler:DeclareProtocol(1, "test2")
            protocol2:AddField(instance.CreateArrayField(instance.CreateNumericField("test"),
                { minLength = 0, maxLength = 50 }))
            protocol2:OnData(OnReceive)
            protocol2:Finalize()

            local data = {}
            for i = 1, 50 do
                table.insert(data, i)
            end

            assert.is_true(protocol1:Send({ test = true }))
            assert.is_true(protocol2:Send({ test = data }))
        end)
    end)
end)
