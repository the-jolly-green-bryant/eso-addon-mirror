var fs = require("fs");
var SAVE_FILE_PATH = "../../../SavedVariables/ChatLogger.lua";
var CHAT_LOG_PATH = "../../../Logs/ChatLog.log";

if(process.versions["nw-flavor"] === "sdk") {
    require('nw.gui').Window.get().showDevTools();
}

var CHAT_CHANNEL_NAME = {};
CHAT_CHANNEL_NAME[0] = "Say";
CHAT_CHANNEL_NAME[1] = "Yell";
CHAT_CHANNEL_NAME[2] = "Incoming Whispers";
CHAT_CHANNEL_NAME[3] = "Group";
CHAT_CHANNEL_NAME[4] = "Outgoing Whispers";
CHAT_CHANNEL_NAME[5] = "Unused 1";
CHAT_CHANNEL_NAME[6] = "Emote";
CHAT_CHANNEL_NAME[7] = "Monster Say";
CHAT_CHANNEL_NAME[8] = "Monster Yell";
CHAT_CHANNEL_NAME[9] = "Monster Whisper";
CHAT_CHANNEL_NAME[10] = "Monster Emote";
CHAT_CHANNEL_NAME[11] = "System";
CHAT_CHANNEL_NAME[12] = "Guild 1";
CHAT_CHANNEL_NAME[13] = "Guild 2";
CHAT_CHANNEL_NAME[14] = "Guild 3";
CHAT_CHANNEL_NAME[15] = "Guild 4";
CHAT_CHANNEL_NAME[16] = "Guild 5";
CHAT_CHANNEL_NAME[17] = "Officer 1";
CHAT_CHANNEL_NAME[18] = "Officer 2";
CHAT_CHANNEL_NAME[19] = "Officer 3";
CHAT_CHANNEL_NAME[20] = "Officer 4";
CHAT_CHANNEL_NAME[21] = "Officer 5";
CHAT_CHANNEL_NAME[22] = "User 1";
CHAT_CHANNEL_NAME[23] = "User 2";
CHAT_CHANNEL_NAME[24] = "User 3";
CHAT_CHANNEL_NAME[25] = "User 4";
CHAT_CHANNEL_NAME[26] = "User 5";
CHAT_CHANNEL_NAME[27] = "User 6";
CHAT_CHANNEL_NAME[28] = "User 7";
CHAT_CHANNEL_NAME[29] = "User 8";
CHAT_CHANNEL_NAME[30] = "User 9";
CHAT_CHANNEL_NAME[31] = "Zone";
CHAT_CHANNEL_NAME[32] = "Zone - English";
CHAT_CHANNEL_NAME[33] = "Zone - French";
CHAT_CHANNEL_NAME[34] = "Zone - German";
CHAT_CHANNEL_NAME[35] = "Zone - Japanese";
CHAT_CHANNEL_NAME[36] = "Zone - Russian";
// these ids don't exist ingame, but we use them for the merged channel names
CHAT_CHANNEL_NAME[100] = "Whisper";
CHAT_CHANNEL_NAME[101] = "NPC";

var CHAT_CHANNEL_FORMAT = {};
CHAT_CHANNEL_FORMAT[-1] = "$time $name: $message"; // default format
CHAT_CHANNEL_FORMAT[0] = "$time $name says: $message";
CHAT_CHANNEL_FORMAT[1] = "$time $name yells: $message";
CHAT_CHANNEL_FORMAT[2] = "$time $name whispers: $message";
CHAT_CHANNEL_FORMAT[4] = "$time To $name: $message";
CHAT_CHANNEL_FORMAT[7] = CHAT_CHANNEL_FORMAT[0];
CHAT_CHANNEL_FORMAT[8] = CHAT_CHANNEL_FORMAT[1];
CHAT_CHANNEL_FORMAT[9] = CHAT_CHANNEL_FORMAT[2];
CHAT_CHANNEL_FORMAT[12] = "$time $guild $name: $message";
CHAT_CHANNEL_FORMAT[13] = CHAT_CHANNEL_FORMAT[12];
CHAT_CHANNEL_FORMAT[14] = CHAT_CHANNEL_FORMAT[12];
CHAT_CHANNEL_FORMAT[15] = CHAT_CHANNEL_FORMAT[12];
CHAT_CHANNEL_FORMAT[16] = CHAT_CHANNEL_FORMAT[12];
CHAT_CHANNEL_FORMAT[17] = CHAT_CHANNEL_FORMAT[12];
CHAT_CHANNEL_FORMAT[18] = CHAT_CHANNEL_FORMAT[12];
CHAT_CHANNEL_FORMAT[19] = CHAT_CHANNEL_FORMAT[12];
CHAT_CHANNEL_FORMAT[20] = CHAT_CHANNEL_FORMAT[12];
CHAT_CHANNEL_FORMAT[21] = CHAT_CHANNEL_FORMAT[12];
CHAT_CHANNEL_FORMAT[31] = "$time $name zone: $message";
CHAT_CHANNEL_FORMAT[32] = "$time $name zone - English: $message";
CHAT_CHANNEL_FORMAT[33] = "$time $name zone - French: $message";
CHAT_CHANNEL_FORMAT[34] = "$time $name zone - German: $message";
CHAT_CHANNEL_FORMAT[35] = "$time $name zone - Japanese: $message";
CHAT_CHANNEL_FORMAT[36] = "$time $name zone - Russian: $message";

var CHAT_CHANNEL_WITHOUT_NAME_BRACKETS = {};
CHAT_CHANNEL_WITHOUT_NAME_BRACKETS[6] = true;
CHAT_CHANNEL_WITHOUT_NAME_BRACKETS[7] = true;
CHAT_CHANNEL_WITHOUT_NAME_BRACKETS[8] = true;
CHAT_CHANNEL_WITHOUT_NAME_BRACKETS[9] = true;
CHAT_CHANNEL_WITHOUT_NAME_BRACKETS[10] = true;

var MERGED_CHAT_CHANNEL = {};
MERGED_CHAT_CHANNEL[2] = 100
MERGED_CHAT_CHANNEL[4] = 100
MERGED_CHAT_CHANNEL[7] = 101
MERGED_CHAT_CHANNEL[8] = 101
MERGED_CHAT_CHANNEL[9] = 101
MERGED_CHAT_CHANNEL[10] = 101

var DEFAULT_COLOR = {};
DEFAULT_COLOR[0] = "#ffffff";
DEFAULT_COLOR[1] = "#c638a1";
DEFAULT_COLOR[2] = "#2dfff8";
DEFAULT_COLOR[3] = "#fd7a1a";
DEFAULT_COLOR[4] = "#5eb9d7";
DEFAULT_COLOR[5] = "#ffffff";
DEFAULT_COLOR[6] = "#a19cde";
DEFAULT_COLOR[7] = "#879b7d";
DEFAULT_COLOR[8] = "#879b7d";
DEFAULT_COLOR[9] = "#879b7d";
DEFAULT_COLOR[10] = "#879b7d";
DEFAULT_COLOR[11] = "#eeee00";
DEFAULT_COLOR[12] = "#55c755";
DEFAULT_COLOR[13] = "#55c755";
DEFAULT_COLOR[14] = "#55c755";
DEFAULT_COLOR[15] = "#55c755";
DEFAULT_COLOR[16] = "#55c755";
DEFAULT_COLOR[17] = "#97ffbe";
DEFAULT_COLOR[18] = "#97ffbe";
DEFAULT_COLOR[19] = "#97ffbe";
DEFAULT_COLOR[20] = "#97ffbe";
DEFAULT_COLOR[21] = "#97ffbe";
DEFAULT_COLOR[22] = "#ffffff";
DEFAULT_COLOR[23] = "#ffffff";
DEFAULT_COLOR[24] = "#ffffff";
DEFAULT_COLOR[25] = "#ffffff";
DEFAULT_COLOR[26] = "#ffffff";
DEFAULT_COLOR[27] = "#ffffff";
DEFAULT_COLOR[28] = "#ffffff";
DEFAULT_COLOR[29] = "#ffffff";
DEFAULT_COLOR[30] = "#ffffff";
DEFAULT_COLOR[31] = "#c5c29e";
DEFAULT_COLOR[32] = "#c5a673";
DEFAULT_COLOR[33] = "#8bc5b3";
DEFAULT_COLOR[34] = "#b192c5";
DEFAULT_COLOR[35] = "#c5c29e";
DEFAULT_COLOR[36] = "#c5c29e";
// these ids don't exist ingame, but we use them for the merged channel names
DEFAULT_COLOR[100] = "#2dfff8";
DEFAULT_COLOR[101] = "#879b7d";

function GetChannelName(channel) {
	return CHAT_CHANNEL_NAME[channel];
}

let timeRangeStart, timeRangeEnd;

$(document).ready(() => {
	var $body = $("body");
	var $channelList = $("#channelList");

	if (!fs.existsSync(SAVE_FILE_PATH)) {
		$body.html("<div>Saved Variables file not found.<br/>Please make sure you have installed the addon correctly and logged out once.</div>")
				.addClass("warning");
	} else if (!fs.existsSync(CHAT_LOG_PATH)) {
		$body.html("<div>Chat log file not found.<br/>Please make sure you have installed the addon correctly and logged out once.</div>").addClass(
				"warning");
	} else {
		parseSavedVariables(function(colors) {
			var chatMessages = [];
			var minDate = new Date();
			var maxDate = new Date(0);
			parseChatLog(function(entry) {
			    if(entry.date < minDate) { minDate = entry.date; }
			    if(entry.date > maxDate) { maxDate = entry.date; }
			    var channel = entry.channel;
				var messages = chatMessages[channel] || [];
				messages.push(entry);
				chatMessages[channel] = messages;
			}, function() {
			    let chatLog = new Clusterize({
			        scrollId: "scrollArea",
			        contentId: "contentArea",
			        rows_in_block: 80
			    });

				chatMessages.forEach(function(messages, channel) {
					var $entry = $("<li></li>").appendTo($channelList);
					var $button = $("<button>" + GetChannelName(channel) + "</button>").appendTo($entry)
					$button.data("channel", channel);
					$button.addClass("active");
					if(colors[channel]) {
					    $button.css("color", colors[channel].messageColor);
					} else {
                        $button.css("color", DEFAULT_COLOR[channel] || "#ffffff");
                    }
					$button.on("click", function() {
						$button.toggleClass("active");
						updateChatHistory(chatLog, chatMessages, colors);
					});
				})

				let $timeRange = $("#timeRange>input");
                timeRangeStart = moment().startOf("day");
                timeRangeEnd = moment().endOf("day");
                $timeRange.daterangepicker({
                    "autoUpdateInput": false,
	                "showDropdowns": true,
	                "timePicker": true,
	                "timePicker24Hour": true,
	                "alwaysShowCalendars": true,
	                "startDate": timeRangeStart,
	                "endDate": timeRangeEnd,
	                "minDate": minDate,
	                "maxDate": maxDate,
	                "drops": "up",
	                "linkedCalendars": false,
	                "locale": {
	                    "format": "YYYY-MM-DD hh:mm"
	                },
	                ranges: {
	                    'Today': [moment().startOf("day"), moment().endOf("day")],
	                    'Yesterday': [moment().subtract(1, 'days').startOf("day"), moment().subtract(1, 'days').endOf("day")],
	                    'Last 7 Days': [moment().subtract(6, 'days').startOf("day"), moment().endOf("day")],
	                    'Last 30 Days': [moment().subtract(29, 'days').startOf("day"), moment().endOf("day")],
	                    'This Month': [moment().startOf('month'), moment().endOf('month')],
	                    'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')],
	                    'All Time': [minDate, maxDate]
	                },
	            }, function(start, end, label) {
	                console.log(start, end, label)
	                $timeRange.val(label);
	                timeRangeStart = start;
	                timeRangeEnd = end;
                    updateChatHistory(chatLog, chatMessages, colors);
	            });
                $timeRange.val('Today');
                updateChatHistory(chatLog, chatMessages, colors);
			});
		}); 
	}

	initializePatreon($("#chatHistory"));
});

function updateChatHistory(chatLog, chatMessages, colors) {
    let start = timeRangeStart.toDate();
    let end = timeRangeEnd.toDate();

    var messageList = [];
	$("#channelList").find("button.active").each(function() {
		var channel = $(this).data("channel");
		messageList = messageList.concat(chatMessages[channel]);
	});
	messageList.sort(function(a, b) {
		return a.date - b.date;
	});

	var rowData = [];
	var lastDate;
	for (var i = 0; i < messageList.length; ++i) {
		var messageData = messageList[i];
		if(messageData.date < start || messageData.date > end) {
		    continue;
		}

        if(!messageData.formattedMessage) {
            messageData.formattedMessage = formatMessage(messageData, colors);
            messageData.formattedDate = formatMessageDate(messageData.date);
        }

		var date = messageData.formattedDate;
		if (lastDate != date) {
			rowData.push(date);
			lastDate = date
		}
		rowData.push(messageData.formattedMessage); 
	}
	if(rowData.length === 0) {
	    rowData.push("<div class='end'>No entries match your selected filters</div>")
	}
	rowData.push("<div class='end'>End of Log</div>")
	chatLog.update(rowData);
}

function formatMessageDate(date) {
	var parts = [];
	parts.push("<div class='date'>");
	parts.push(date.getFullYear());
	parts.push("-");
	parts.push(padValue(date.getMonth() + 1));
	parts.push("-");
	parts.push(padValue(date.getDate()));
	parts.push("</div>");
	return parts.join("");
}

function formatSenderName(name, color, hasBrackets) {
    if (hasBrackets) {
        name = `[${name}]`;
    }
    return `<span class="sender" style="color: ${color}">${name}</span>`;
}

function formatMessage(messageData, colors) {
	var originalChannel = messageData.originalChannel;
	var message = messageData.message;
	var channelColors = colors[originalChannel];
	let senderColor, messageColor;
    if(channelColors) {
        senderColor = channelColors.senderColor;
        messageColor = channelColors.messageColor;
    } else {
        senderColor = DEFAULT_COLOR[originalChannel] || "#ffffff";
        messageColor = DEFAULT_COLOR[originalChannel] || "#ffffff";
    }
	var format = CHAT_CHANNEL_FORMAT[originalChannel] || CHAT_CHANNEL_FORMAT[-1];
	var hasNameBrackets = !CHAT_CHANNEL_WITHOUT_NAME_BRACKETS[originalChannel];

	message = message.replace(/\|H(.*?)\|h(.*?)\|h/g, function(match, data, label) {
	    data = data.split(":")
	    let linkType = data[1];
	    if(linkType) {
    		var parts = [];
    		if (label.length > 0) {
    			parts.push(label);
    		} else {
    			parts.push(linkType);
    			let id = data[2];
    			if(id) {
        			parts.push("#");
        			parts.push(id);
    			}
    		}
    		if (data[0] == "1") {
    			parts.unshift("[");
    			parts.push("]");
    		}
            parts.unshift("<span class='link'>");
            parts.push("</span>");
    		return parts.join("");
    	    }
	    return "";
	})

	format = format.replace(/\$time/, formatTime(messageData.date));
	format = format.replace(/\$guild/, formatChannelName(messageData.channel));
	format = format.replace(/\$name/, formatSenderName(messageData.sender, senderColor, hasNameBrackets));
	format = format.replace(/\$message/, message);
	return `<div class="message" style="color: ${messageColor}">${format}</div>`;
}

function padValue(value) {
	return ("00" + value).slice(-2);
}

function formatTime(date) {
    let time = moment(date).format("HH:mm:ss")
	return `<span class="time">[${time}]</span>`;
}

function formatChannelName(channel) {
	let channelName = GetChannelName(channel);
    return `<span class="channel">[${channelName}]</span>`;
}

function parseChatLog(entryHandler, callback) {
	var fd = fs.openSync(CHAT_LOG_PATH, 'r');
	var stream = fs.createReadStream(null, {
		fd : fd,
		autoClose : false
	});
	var lineReader = require('readline').createInterface({
		input : stream
	});

	var contentPattern = /^(.+?) (.+?),(.+?),(.+?)$/;
	var hasSeen = {}; // filter duplicate lines
	let currentEntry;
	lineReader.on('line', function(line) {
	    if(currentEntry && line == "") {
	        currentEntry.message += "\n";
        } else if (!hasSeen[line]) {
			hasSeen[line] = true;
			var matches = line.match(contentPattern);
			var parsed = false;
			if (matches) {
			    let channel = parseInt(matches[2]);
			    if(!isNaN(channel)) {
    			    currentEntry = {};
    			    // the time zone information doesn't respect DST which would
    			    // result in incorrect times
    			    let dateParts = matches[1].split("+")
    			    currentEntry.date = new Date(dateParts[0]);
    			    currentEntry.channel = MERGED_CHAT_CHANNEL[channel] || channel;
    			    currentEntry.originalChannel = channel;
    				currentEntry.sender = matches[3];
    			    currentEntry.message = matches[4];
    				entryHandler(currentEntry);
    				parsed = true;
			    }
			}
            if(!parsed) {
                if(currentEntry) {
                    currentEntry.message += "\n" + line;
                } else {
                    console.warn("line did not match", line);
                }
            }
		}
	});

	lineReader.on('close', function() {
		fs.closeSync(fd);
		callback();
	});
}

function parseSavedVariables(callback) {
	var fd = fs.openSync(SAVE_FILE_PATH, 'r');
	var stream = fs.createReadStream(null, {
		fd : fd,
		autoClose : false
	});
	var lineReader = require('readline').createInterface({
		input : stream
	});

	var colors = []; // for now we assume there is only one array with colors
	// in the file
	var colorPattern = /\[(\d+)\] = "(.+)\|(.+)",/;
	lineReader.on('line', function(line) {
		var matches = line.match(colorPattern);
		if (matches) {
			var channel = parseInt(matches[1]);
			if (!colors[channel]) {
				colors[channel] = {
					senderColor : "#" + matches[2],
					messageColor : "#" + matches[3]
				}
			}
		}
	});

	lineReader.on('close', function() {
		fs.closeSync(fd);
		callback(colors);
	});
}

const PATREON_LINK = 'https://www.patreon.com/bePatron?u=18954089';

function initializePatreon($chatHistory) {
    let $container = $('#patrons');
    let content = fs.readFileSync('res/patrons.json');
    let patrons = JSON.parse(content.toString('utf8'));

    let button = $('#patreon');
    function toggleContainer() {
        if($container.is(":visible")) {
            $chatHistory.show();
            $container.hide();
            button.removeClass("active");
        } else {
            $chatHistory.hide();
            $container.show();
            button.addClass("active");
        }
    }
    button.click(toggleContainer);
    $('#hidePatrons').click(toggleContainer);

    let becomePatron = $container.find('#becomePatron');
    becomePatron.click(() => {
        window.require('nw.gui').Shell.openExternal(PATREON_LINK);
    });

    let activeList = $container.find('#activeList');
    let formerList = $container.find('#formerList');

    shuffleArray(patrons.active);
    patrons.active.forEach(patron => {
        $('<span></span>').text(patron.name)
            .addClass('emph' + patron.tier)
            .appendTo(activeList);
    });

    shuffleArray(patrons.former);
    patrons.former.forEach(patron => {
        $('<span></span>').text(patron.name)
            .addClass('emph' + patron.tier)
            .appendTo(formerList);
    });

    let showFormerList = false;
    let formerButton = $("#formerContainer button");
    formerButton.click((e) => {
        showFormerList = !showFormerList;
        if (showFormerList) {
            formerList.show();
            formerButton.addClass("active");
        }
        else {
            formerList.hide();
            formerButton.removeClass("active");
        }
    });
}

// https://stackoverflow.com/questions/2450954/how-to-randomize-shuffle-a-javascript-array
function shuffleArray(array) {
    for (let i = array.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [array[i], array[j]] = [array[j], array[i]];
    }
}