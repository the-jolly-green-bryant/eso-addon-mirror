TextFormatter = {

    success = function(text)
        return TextFormatter.toString('28a745', text)
    end,

    primary = function(text)
        return TextFormatter.toString('007bff', text)
    end,

    error = function(text)
        return TextFormatter.toString('dc3545', text)
    end,

    warning = function(text)
        return TextFormatter.toString('ffc107', text)
    end,

    info = function(text)
        return TextFormatter.toString('17a2b8', text)
    end,

    toString = function(colour, text)
        return string.format('|c%s%s|r', colour, text)
    end
}

function print_info(text)
    text = TextFormatter.info(text)
    print_chat(text)
end

function print_primary(text)
    text = TextFormatter.primary(text)
    print_chat(text)
end

function print_success(text)
    text = TextFormatter.success(text)
    print_chat(text)
end

function print_error(text)
    text = TextFormatter.error(text)
    print_chat(text)
end

function print_warning(text)
    text = TextFormatter.warning(text)
    print_chat(text)
end

function print_chat(text)
    CHAT_SYSTEM.AddMessage(CHAT_SYSTEM, text)
end
