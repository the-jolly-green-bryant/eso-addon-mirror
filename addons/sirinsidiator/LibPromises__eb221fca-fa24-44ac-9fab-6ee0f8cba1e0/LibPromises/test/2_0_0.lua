-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end

Taneth("LibPromises", function()
    local Promise = LibPromises
    local rejected = LibPromiseTest.rejected
    local dummy = { dummy = "dummy" } -- we fulfill or reject with this when we don't intend to test against it

    describe("Custom: A promise for ESO", function()
        it.async("should survive metatable pollution", function(done)
            local DummyClass = ZO_InitializingObject:Subclass()
            getmetatable(DummyClass).__call = function() end

            local Base = ZO_InitializingObject:Subclass()
            local Other = Base:Subclass()
            function Other:New(...)
                return Base.New(self, ...)
            end

            function Other:A()
                return self:B():Then(self.C)
            end

            function Other:B()
                local promise = Promise:New()
                zo_callLater(function()
                    promise:Resolve(self)
                end, 1)
                return promise
            end

            function Other:C()
                local promise = Promise:New()
                promise:Resolve(self)
                return promise
            end

            local obj = Other:New()
            obj:A():Then(function()
                ZO_InitializingObject.__call = nil
                done()
            end)
        end)

        describe("has to report unhandled promise rejections", function()
            it.async("when it is rejected", function(done)
                local handler = spy.new(function(p)
                    assert.equals(dummy, p.value)
                end)
                Promise:SetUnhandledRejectionHandler(handler)

                rejected(dummy)
                assert.spy(handler).was_not.called()

                zo_callLater(function()
                    assert.spy(handler).was.called(1)
                    Promise:SetUnhandledRejectionHandler(nil)
                    done()
                end, 100)
            end)

            it.async("on error in a rejected promise with no follow up handlers", function(done)
                local handler, value
                handler = spy.new(function(p)
                    value = p.value
                end)
                Promise:SetUnhandledRejectionHandler(handler)

                local promise = Promise:New()
                promise:Then(nil, function(e)
                    error("test")
                end)
                promise:Reject(dummy)

                zo_callLater(function()
                    assert.spy(handler).was.called(1)
                    assert.equals("string", type(value))
                    assert.equals("test", string.sub(value, -4))
                    Promise:SetUnhandledRejectionHandler(nil)
                    done()
                end, 100)
            end)

            it.async("on error in a rejected promise unless there is a follow up handler", function(done)
                local handler = spy.new(function(p) end)
                Promise:SetUnhandledRejectionHandler(handler)

                local value
                local promise = Promise:New()
                promise:Then(nil, function(e)
                    error("test")
                end):Then(nil, function(e)
                    value = e
                end)
                promise:Reject(dummy)

                zo_callLater(function()
                    assert.spy(handler).was_not.called()
                    assert.equals("string", type(value))
                    assert.equals("test", string.sub(value, -4))
                    Promise:SetUnhandledRejectionHandler(nil)
                    done()
                end, 100)
            end)
        end)
    end)
end)
