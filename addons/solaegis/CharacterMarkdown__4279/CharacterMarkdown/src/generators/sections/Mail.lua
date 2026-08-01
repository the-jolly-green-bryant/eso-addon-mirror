-- CharacterMarkdown - Mail Section Generator

local CM = CharacterMarkdown

local function GenerateMail(mailData)
    local markdown = ""
    local GenerateAnchor = CM.utils and CM.utils.markdown and CM.utils.markdown.GenerateAnchor
    local anchorId = GenerateAnchor and GenerateAnchor("📬 Mail") or "mail"
    markdown = markdown .. string.format('<a id="%s"></a>\n\n', anchorId)
    markdown = markdown .. "## 📬 Mail\n\n"

    local mailList = mailData and mailData.list or {}
    if not mailList or #mailList == 0 then
        markdown = markdown .. "*No mail in inbox*\n\n"
        return markdown
    end

    local CreateStyledTable = CM.utils.markdown and CM.utils.markdown.CreateStyledTable
    if CreateStyledTable then
        local headers = { "From", "Subject", "Status" }
        local rows = {}
        for _, mail in ipairs(mailList) do
            local status = mail.isRead and "Read" or "Unread"
            if mail.hasAttachments then
                status = status .. " (attachments)"
            end
            table.insert(rows, {
                mail.sender or "Unknown",
                mail.subject or "(no subject)",
                status,
            })
        end
        local options = {
            alignment = { "left", "left", "left" },
            coloredHeaders = true,
        }
        markdown = markdown .. CreateStyledTable(headers, rows, options)
        markdown = markdown .. "\n"
    else
        for _, mail in ipairs(mailList) do
            local status = mail.isRead and "Read" or "Unread"
            markdown = markdown
                .. string.format(
                    "- **%s** — %s (%s)\n",
                    mail.sender or "Unknown",
                    mail.subject or "(no subject)",
                    status
                )
        end
        markdown = markdown .. "\n"
    end

    if mailData and mailData.summary then
        local summary = mailData.summary
        markdown = markdown
            .. string.format(
                "*%d message(s), %d unread, %d with attachments*\n\n",
                summary.totalMail or #mailList,
                summary.unreadCount or 0,
                summary.attachmentCount or 0
            )
    end

    return markdown
end

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateMail = GenerateMail
