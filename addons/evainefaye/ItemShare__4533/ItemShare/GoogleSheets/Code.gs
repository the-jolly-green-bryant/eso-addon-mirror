const APP_TITLE = 'ESO Item Share';
const EXPECTED_WINDOWS_PATH = String.raw`Documents\Elder Scrolls Online\live\SavedVariables\ItemShare.lua`;

const MASTER_SHEET_NAME = 'Master';
const BATCH_UPDATE_FLAG_KEY = 'ITEMSHARE_BATCH_UPDATING';
const LAST_HIGHLIGHTED_ROW_KEY = 'ITEMSHARE_LAST_HIGHLIGHTED_ROW';
const LAST_HIGHLIGHTED_SHEET_KEY = 'ITEMSHARE_LAST_HIGHLIGHTED_SHEET';

const HEADER_ROW = ['Name', 'Item Type', 'Quality', 'Trait', 'Date Added', 'Count', 'RequestedBy', 'Location', 'SyncKey'];
const MASTER_HEADER_ROW = ['Name', 'Item Type', 'Quality', 'Trait', 'Date Added', 'Count', 'RequestedBy', 'Source Sheet', 'SyncKey'];

const COL_NAME = 1;
const COL_ITEM_TYPE = 2;
const COL_QUALITY = 3;
const COL_TRAIT = 4;
const COL_DATE_ADDED = 5;
const COL_COUNT = 6;
const COL_REQUESTED_BY = 7;
const COL_LOCATION = 8;
const COL_SYNC_KEY = 9;

const MASTER_COL_REQUESTED_BY = 7;
const MASTER_COL_SOURCE_SHEET = 8;
const MASTER_COL_SYNC_KEY = 9;

const UI_PANEL_START_COL = 11; // K
const UI_PANEL_WIDTH = 4;      // K:N
const DOCUMENT_LOCK_TIMEOUT_MS = 30000;

function withDocumentLock_(callback) {
  const lock = LockService.getDocumentLock();
  lock.waitLock(DOCUMENT_LOCK_TIMEOUT_MS);
  try {
    return callback();
  } finally {
    lock.releaseLock();
  }
}

function tryWithDocumentLock_(callback) {
  const lock = LockService.getDocumentLock();
  if (!lock.tryLock(5000)) {
    return false;
  }
  try {
    callback();
    return true;
  } finally {
    lock.releaseLock();
  }
}

function onOpen() {
  SpreadsheetApp.getUi()
    .createMenu('Item Share')
    .addItem('Open Updater', 'showUploadDialog')
    .addItem('Reset/format active account sheet', 'prepareActiveSheetForImports')
    .addToUi();

  try {
    activateMasterSheet_(); // always force open to Master
  } catch (err) {}
}

function showUploadDialog() {
  const html = HtmlService.createHtmlOutputFromFile('UploadDialog')
    .setWidth(560)
    .setHeight(480);
  SpreadsheetApp.getUi().showModalDialog(html, 'Update ESO Item Share Sheet');
}

function getUploaderConfig() {
  return {
    appTitle: APP_TITLE,
    expectedWindowsPath: EXPECTED_WINDOWS_PATH
  };
}

function processUploadedSavedVariables(fileText) {
  return withDocumentLock_(function() {
  if (!fileText || !String(fileText).trim()) {
    throw new Error('No file content was received.');
  }

  setBatchUpdateInProgress_(true);
  try {
    const parsedAccounts = parseAllSavedVariablesAccounts_(String(fileText));
    if (!parsedAccounts.length) {
      throw new Error('Could not find any ESO account sections with shared items in the saved variables file.');
    }

    let totalImportedItems = 0;
    let totalUpdatedRows = 0;
    let totalInsertedRows = 0;
    let totalRemovedRows = 0;
    const updatedSheets = [];

    parsedAccounts.forEach(parsed => {
      const groupedItems = aggregateImportedItems_(parsed.items);
      const sheet = getOrCreateAccountSheet_(parsed.accountName);
      initializeAccountSheet_(sheet);

      const existingRows = readExistingRows_(sheet, false);
      const updates = mergeImportedRows_(existingRows, groupedItems);
      writeRows_(sheet, updates.rows, false);
      sortAccountSheet_(sheet);
      autoSizeLocationColumn_(sheet);

      totalImportedItems += groupedItems.length;
      totalUpdatedRows += updates.updatedRows;
      totalInsertedRows += updates.insertedRows;
      totalRemovedRows += updates.removedRows || 0;
      updatedSheets.push(sheet.getName());
    });

    rebuildMasterSheet_();
    activateMasterSheet_();
    SpreadsheetApp.flush();

    return {
      accountName: parsedAccounts.length === 1 ? parsedAccounts[0].accountName : parsedAccounts.length + ' accounts',
      importedItems: totalImportedItems,
      sheetName: updatedSheets.join(', '),
      updatedRows: totalUpdatedRows,
      insertedRows: totalInsertedRows,
      removedRows: totalRemovedRows
    };
  } finally {
    setBatchUpdateInProgress_(false);
  }
  });
}

function prepareActiveSheetForImports() {
  return withDocumentLock_(function() {
    const sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
    if (sheet.getName() === MASTER_SHEET_NAME) {
      initializeMasterSheet_(sheet);
    } else {
      initializeAccountSheet_(sheet);
    }
    SpreadsheetApp.getActive().toast('Active sheet prepared.', APP_TITLE, 5);
  });
}

function getOrCreateAccountSheet_(accountName) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const cleanName = sanitizeSheetName_(accountName);
  let sheet = ss.getSheetByName(cleanName);
  if (!sheet) {
    sheet = ss.insertSheet(cleanName);
  }
  return sheet;
}

function getOrCreateMasterSheet_() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  let sheet = ss.getSheetByName(MASTER_SHEET_NAME);
  if (!sheet) {
    sheet = ss.insertSheet(MASTER_SHEET_NAME, 1);
  }
  return sheet;
}

function activateMasterSheet_() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const master = getOrCreateMasterSheet_();
  ss.setActiveSheet(master);
  ss.moveActiveSheet(1);
  ensureMasterControlPanel_();
}

function sanitizeSheetName_(name) {
  let clean = String(name || '').trim() || 'Unknown Account';
  clean = clean.replace(/[\\\/\?\*\[\]\:]/g, '_');
  if (clean.length > 99) clean = clean.slice(0, 99);
  return clean;
}

function migrateLegacyAccountSheetLayout_(sheet) {
  const lastColumn = sheet.getLastColumn();
  if (lastColumn < 9) return;

  const headerValues = sheet.getRange(1, 1, 1, 9).getValues()[0].map(v => String(v || '').trim());
  const hasOldLayout = headerValues[6] === 'Location' && headerValues[7] === 'RequestedBy' && headerValues[8] === 'SyncKey';

  if (hasOldLayout) {
    const lastRow = sheet.getLastRow();
    if (lastRow >= 2) {
      const range = sheet.getRange(2, 1, lastRow - 1, 9);
      const values = range.getValues();
      values.forEach(function(row) {
        const location = row[6];
        const requestedBy = row[7];
        row[6] = requestedBy;
        row[7] = location;
      });
      range.setValues(values);
    }
  }
}

function initializeAccountSheet_(sheet) {
  migrateLegacyAccountSheetLayout_(sheet);
  initializeSheetCommon_(sheet, HEADER_ROW);
  sheet.getRange('A:A').setNumberFormat('@');
  sheet.getRange('B:B').setNumberFormat('@');
  sheet.getRange('C:C').setNumberFormat('@');
  sheet.getRange('D:D').setNumberFormat('@');
  sheet.getRange('E:E').setNumberFormat('yyyy-mm-dd');
  sheet.getRange('F:F').setNumberFormat('0');
  sheet.getRange('G:G').setNumberFormat('@');
  sheet.getRange('H:H').setNumberFormat('@');
  sheet.getRange('I:I').setNumberFormat('@');

  sheet.setColumnWidths(1, 1, 280);
  sheet.setColumnWidths(2, 1, 130);
  sheet.setColumnWidths(3, 1, 110);
  sheet.setColumnWidths(4, 1, 150);
  sheet.setColumnWidths(5, 1, 130);
  sheet.setColumnWidths(6, 1, 80);
  autoSizeLocationColumn_(sheet);
  sheet.setColumnWidths(8, 1, 180);
  safeHideColumn_(sheet, COL_SYNC_KEY);
  applyAlternatingRowColors_(sheet, false);
}


function autoSizeLocationColumn_(sheet) {
  const lastRow = Math.max(sheet.getLastRow(), 1);
  const values = sheet.getRange(1, COL_LOCATION, lastRow, 1).getDisplayValues();
  let maxLen = 0;
  values.forEach(function(row) {
    const len = String((row && row[0]) || '').length;
    if (len > maxLen) maxLen = len;
  });
  const width = Math.max(180, Math.min(700, Math.round(maxLen * 7 + 24)));
  sheet.setColumnWidth(COL_LOCATION, width);
}

function initializeMasterSheet_(sheet) {
  initializeSheetCommon_(sheet, MASTER_HEADER_ROW);
  sheet.getRange('A:A').setNumberFormat('@');
  sheet.getRange('B:B').setNumberFormat('@');
  sheet.getRange('C:C').setNumberFormat('@');
  sheet.getRange('D:D').setNumberFormat('@');
  sheet.getRange('E:E').setNumberFormat('yyyy-mm-dd');
  sheet.getRange('F:F').setNumberFormat('0');
  sheet.getRange('G:G').setNumberFormat('@');
  sheet.getRange('H:H').setNumberFormat('@');
  sheet.getRange('I:I').setNumberFormat('@');

  sheet.setColumnWidths(1, 1, 280);
  sheet.setColumnWidths(2, 1, 130);
  sheet.setColumnWidths(3, 1, 110);
  sheet.setColumnWidths(4, 1, 150);
  sheet.setColumnWidths(5, 1, 130);
  sheet.setColumnWidths(6, 1, 80);
  sheet.setColumnWidths(7, 1, 160);
  sheet.setColumnWidths(8, 1, 180);
  safeHideColumn_(sheet, MASTER_COL_SYNC_KEY);
  applyAlternatingRowColors_(sheet, true);
}

function ensureMasterControlPanel_() {
  const master = getOrCreateMasterSheet_();

  if (master.getMaxColumns() < UI_PANEL_START_COL + UI_PANEL_WIDTH - 1) {
    master.insertColumnsAfter(master.getMaxColumns(), (UI_PANEL_START_COL + UI_PANEL_WIDTH - 1) - master.getMaxColumns());
  }

  master.setColumnWidths(UI_PANEL_START_COL, 1, 150);
  master.setColumnWidths(UI_PANEL_START_COL + 1, UI_PANEL_WIDTH - 1, 110);

  const panelRange = master.getRange(1, UI_PANEL_START_COL, 10, UI_PANEL_WIDTH);
  panelRange.clearFormat();
  panelRange.clearNote();
  panelRange.breakApart();
  panelRange.setBackground('#ffffff');

  const titleRange = master.getRange(1, UI_PANEL_START_COL, 1, UI_PANEL_WIDTH).merge();
  titleRange
    .setValue('ESO Item Share')
    .setFontWeight('bold')
    .setFontSize(14)
    .setHorizontalAlignment('center')
    .setVerticalAlignment('middle')
    .setBackground('#1f4e78')
    .setFontColor('#ffffff');

  const buttonRange = master.getRange(3, UI_PANEL_START_COL, 2, UI_PANEL_WIDTH).merge();
  buttonRange
    .setValue('UPLOAD ITEMS\nUse Item Share → Open Updater')
    .setFontWeight('bold')
    .setFontSize(12)
    .setHorizontalAlignment('center')
    .setVerticalAlignment('middle')
    .setWrap(true)
    .setBackground('#1a73e8')
    .setFontColor('#ffffff')
    .setBorder(true, true, true, true, true, true, '#0b57d0', SpreadsheetApp.BorderStyle.SOLID_MEDIUM);
  buttonRange.setNote('Google Sheets drawings can have assigned script actions, but this script builds a sheet-based control panel instead. Open the uploader from the Item Share menu.');

  const infoRange = master.getRange(6, UI_PANEL_START_COL, 4, UI_PANEL_WIDTH).merge();
  infoRange
    .setValue(
      'How to update:\n' +
      '1) Click Item Share\n' +
      '2) Choose Open Updater\n' +
      '3) Select ItemShare.lua\n' +
      '4) Click Update Sheet'
    )
    .setWrap(true)
    .setVerticalAlignment('top')
    .setHorizontalAlignment('left')
    .setBackground('#f8f9fa')
    .setFontColor('#202124')
    .setBorder(true, true, true, true, true, true, '#dadce0', SpreadsheetApp.BorderStyle.SOLID);

  master.setRowHeights(1, 1, 28);
  master.setRowHeights(3, 2, 32);
  master.setRowHeights(6, 4, 24);
}

function initializeSheetCommon_(sheet, headerRow) {
  sheet.clearConditionalFormatRules();

  if (sheet.getMaxRows() < 2) {
    sheet.insertRowsAfter(sheet.getMaxRows(), 1);
  }
  if (sheet.getMaxColumns() < headerRow.length) {
    sheet.insertColumnsAfter(sheet.getMaxColumns(), headerRow.length - sheet.getMaxColumns());
  }

  sheet.getRange(1, 1, 1, headerRow.length).setValues([headerRow]);
  sheet.setFrozenRows(1);

  const headerRange = sheet.getRange(1, 1, 1, headerRow.length);
  headerRange
    .setFontWeight('bold')
    .setBackground('#1f4e78')
    .setFontColor('#ffffff')
    .setHorizontalAlignment('center');

  const existingFilter = sheet.getFilter();
  if (existingFilter) existingFilter.remove();

  const filterRows = Math.max(sheet.getLastRow(), 2);
  sheet.getRange(1, 1, filterRows, headerRow.length).createFilter();
}

function applyAlternatingRowColors_(sheet, isMaster) {
  const columnCount = isMaster ? MASTER_HEADER_ROW.length : HEADER_ROW.length;
  const existingRules = sheet.getConditionalFormatRules() || [];
  const preservedRules = existingRules.filter(rule => {
    try {
      const ranges = rule.getRanges() || [];
      return !ranges.some(range =>
        range.getSheet().getSheetId() === sheet.getSheetId() &&
        range.getRow() === 2 &&
        range.getColumn() === 1 &&
        range.getNumColumns() === columnCount
      );
    } catch (err) {
      return true;
    }
  });

  const rowCount = Math.max(sheet.getMaxRows() - 1, 1);
  const range = sheet.getRange(2, 1, rowCount, columnCount);

  const alternatingRule = SpreadsheetApp.newConditionalFormatRule()
    .whenFormulaSatisfied('=ISEVEN(ROW())')
    .setBackground('#f8f9fa')
    .setRanges([range])
    .build();

  preservedRules.push(alternatingRule);
  sheet.setConditionalFormatRules(preservedRules);
}

function readExistingRows_(sheet, isMaster) {
  const headers = isMaster ? MASTER_HEADER_ROW : HEADER_ROW;
  const lastRow = sheet.getLastRow();
  if (lastRow < 2) return [];

  const values = sheet.getRange(2, 1, lastRow - 1, headers.length).getValues();

  return values
    .filter(row => row[0])
    .map(row => ({
      name: String(row[0]).trim(),
      itemType: String(row[1] || '').trim(),
      quality: String(row[2] || '').trim(),
      trait: String(row[3] || '').trim(),
      dateAdded: row[4] instanceof Date ? row[4] : null,
      count: Number(row[5]) || 0,
      requestedBy: String(row[6] || '').trim(),
      location: isMaster ? '' : String(row[7] || '').trim(),
      sourceSheet: isMaster ? String(row[7] || '').trim() : sheet.getName(),
      syncKey: String(row[8] || '').trim()
    }));
}

function mergeImportedRows_(existingRows, importedItems) {
  const existingBySyncKey = new Map();
  const existingByLegacyKey = new Map();
  let updatedRows = 0;
  let insertedRows = 0;
  let removedRows = 0;

  existingRows.forEach(row => {
    const normalized = {
      name: row.name,
      itemType: row.itemType,
      quality: row.quality,
      trait: row.trait,
      dateAdded: row.dateAdded,
      count: row.count,
      location: row.location || '',
      requestedBy: row.requestedBy,
      syncKey: row.syncKey || buildLegacySyncKey_(row.name, row.itemType, row.quality, row.trait)
    };

    if (normalized.syncKey) {
      existingBySyncKey.set(normalized.syncKey, normalized);
    }

    existingByLegacyKey.set(buildLegacyRowKey_(row.name, row.itemType, row.quality, row.trait), normalized);
  });

  const importedSyncKeys = new Set();
  const rows = importedItems.map(item => {
    const syncKey = buildImportedSyncKey_(item);
    const legacyKey = buildLegacyRowKey_(item.name, item.itemTypeName, item.qualityName, item.trait);
    importedSyncKeys.add(syncKey);

    const existing = existingBySyncKey.get(syncKey) || existingByLegacyKey.get(legacyKey);

    if (existing) {
      updatedRows += 1;
      return {
        name: item.name,
        itemType: item.itemTypeName,
        quality: item.qualityName,
        trait: item.trait,
        dateAdded: existing.dateAdded || unixToDate_(item.firstDumpedAt),
        count: item.count,
        location: item.sharedFrom || existing.location || '',
        requestedBy: existing.requestedBy || '',
        syncKey
      };
    }

    insertedRows += 1;
    return {
      name: item.name,
      itemType: item.itemTypeName,
      quality: item.qualityName,
      trait: item.trait,
      dateAdded: unixToDate_(item.firstDumpedAt),
      count: item.count,
      location: item.sharedFrom || '',
      requestedBy: '',
      syncKey
    };
  });

  existingRows.forEach(row => {
    const priorSyncKey = row.syncKey || buildLegacySyncKey_(row.name, row.itemType, row.quality, row.trait);
    if (!importedSyncKeys.has(priorSyncKey)) {
      removedRows += 1;
    }
  });

  rows.sort((a, b) => {
    return compareText_(a.itemType, b.itemType) ||
      compareText_(a.name, b.name) ||
      compareText_(a.quality, b.quality) ||
      compareText_(a.trait, b.trait);
  });

  return { rows, updatedRows, insertedRows, removedRows };
}

function buildLegacyRowKey_(name, itemType, quality, trait) {
  return [
    String(name || '').trim().toLowerCase(),
    String(itemType || '').trim().toLowerCase(),
    String(quality || '').trim().toLowerCase(),
    String(trait || '').trim().toLowerCase()
  ].join('\u001f');
}

function buildLegacySyncKey_(name, itemType, quality, trait) {
  return ['LEGACY', name || '', itemType || '', quality || '', trait || ''].join('||');
}

function buildItemLinkSyncKey_(itemLink) {
  return ['ITEMLINK', itemLink || ''].join('||');
}

function buildImportedSyncKey_(item) {
  if (item && item.itemLink) {
    return buildItemLinkSyncKey_(item.itemLink);
  }
  return buildLegacySyncKey_(item.name, item.itemTypeName, item.qualityName, item.trait);
}

function compareText_(a, b) {
  return String(a || '').localeCompare(String(b || ''), undefined, { sensitivity: 'base' });
}

function aggregateImportedItems_(items) {
  const grouped = new Map();

  (items || []).forEach(item => {
    if (!item) return;

    const syncKey = buildImportedSyncKey_(item);
    const existing = grouped.get(syncKey);

    if (!existing) {
      const clone = Object.assign({}, item);
      clone.count = Number(item.count) || 0;
      clone._locationSet = new Set();

      splitLocationList_(item.sharedFrom).forEach(location => clone._locationSet.add(location));
      grouped.set(syncKey, clone);
      return;
    }

    existing.count += Number(item.count) || 0;

    splitLocationList_(item.sharedFrom).forEach(location => existing._locationSet.add(location));

    const existingFirst = Number(existing.firstDumpedAt) || 0;
    const incomingFirst = Number(item.firstDumpedAt) || 0;
    if (!existingFirst || (incomingFirst && incomingFirst < existingFirst)) {
      existing.firstDumpedAt = incomingFirst || existing.firstDumpedAt;
    }

    const existingLast = Number(existing.lastDumpedAt) || 0;
    const incomingLast = Number(item.lastDumpedAt) || 0;
    if (incomingLast > existingLast) {
      existing.lastDumpedAt = incomingLast;
    }
  });

  const results = Array.from(grouped.values()).map(item => {
    item.sharedFrom = joinSortedLocations_(item._locationSet);
    delete item._locationSet;
    return item;
  });

  results.sort((a, b) => {
    return compareText_(a.itemTypeName, b.itemTypeName) ||
      compareText_(a.name, b.name) ||
      compareText_(a.qualityName, b.qualityName) ||
      compareText_(a.trait, b.trait);
  });

  return results;
}

function splitLocationList_(value) {
  return String(value || '')
    .split(',')
    .map(part => part.trim())
    .filter(Boolean);
}

function joinSortedLocations_(locationSet) {
  return Array.from(locationSet || [])
    .sort((a, b) => compareText_(a, b))
    .join(', ');
}

function writeRows_(sheet, rows, isMaster) {
  const headers = isMaster ? MASTER_HEADER_ROW : HEADER_ROW;
  const dataRowCount = Math.max(sheet.getLastRow() - 1, 0);

  if (dataRowCount > 0) {
    sheet.getRange(2, 1, dataRowCount, headers.length).clearContent();
  }

  if (rows.length === 0) return;

  const totalRowsNeeded = rows.length + 1;
  if (sheet.getMaxRows() < totalRowsNeeded) {
    sheet.insertRowsAfter(sheet.getMaxRows(), totalRowsNeeded - sheet.getMaxRows());
  }

  const values = rows.map(row => isMaster ? [
    row.name,
    row.itemType,
    row.quality,
    row.trait,
    row.dateAdded || '',
    row.count,
    row.requestedBy || '',
    row.sourceSheet || '',
    row.syncKey || ''
  ] : [
    row.name,
    row.itemType,
    row.quality,
    row.trait,
    row.dateAdded || '',
    row.count,
    row.requestedBy || '',
    row.location || '',
    row.syncKey || ''
  ]);

  sheet.getRange(2, 1, values.length, headers.length).setValues(values);
}

function sortAccountSheet_(sheet) {
  const lastRow = sheet.getLastRow();
  if (lastRow <= 2) return;

  sheet.getRange(2, 1, lastRow - 1, HEADER_ROW.length).sort([
    { column: COL_NAME, ascending: true },
    { column: COL_ITEM_TYPE, ascending: true },
    { column: COL_QUALITY, ascending: true },
    { column: COL_TRAIT, ascending: true }
  ]);
}

function sortMasterSheet_(sheet) {
  const lastRow = sheet.getLastRow();
  if (lastRow <= 2) return;

  sheet.getRange(2, 1, lastRow - 1, MASTER_HEADER_ROW.length).sort([
    { column: COL_NAME, ascending: true },
    { column: COL_ITEM_TYPE, ascending: true },
    { column: COL_QUALITY, ascending: true },
    { column: COL_TRAIT, ascending: true },
    { column: MASTER_COL_SOURCE_SHEET, ascending: true }
  ]);
}

function rebuildMasterSheet_() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const master = getOrCreateMasterSheet_();
  initializeMasterSheet_(master);

  const rows = [];
  ss.getSheets().forEach(sheet => {
    const name = sheet.getName();
    if (name === MASTER_SHEET_NAME) return;

    const existing = readExistingRows_(sheet, false);
    existing.forEach(row => {
      rows.push({
        name: row.name,
        itemType: row.itemType,
        quality: row.quality,
        trait: row.trait,
        dateAdded: row.dateAdded,
        count: row.count,
        requestedBy: row.requestedBy,
        sourceSheet: name,
        syncKey: row.syncKey || buildLegacySyncKey_(row.name, row.itemType, row.quality, row.trait)
      });
    });
  });
  writeRows_(master, rows, true);
  sortMasterSheet_(master);
  SpreadsheetApp.getActiveSpreadsheet().setActiveSheet(master);
  SpreadsheetApp.getActiveSpreadsheet().moveActiveSheet(1);
}

function unixToDate_(epochSeconds) {
  const n = Number(epochSeconds);
  if (!n) return '';
  return new Date(n * 1000);
}

function parseAllSavedVariablesAccounts_(text) {
  const defaultIndex = text.indexOf('["Default"]');
  if (defaultIndex === -1) {
    throw new Error('Could not find the Default saved variables section.');
  }

  const defaultOpenBrace = text.indexOf('{', defaultIndex);
  if (defaultOpenBrace === -1) {
    throw new Error('Could not parse the Default saved variables section.');
  }

  const defaultCloseBrace = findMatchingBrace_(text, defaultOpenBrace);
  const defaultBlock = text.slice(defaultOpenBrace + 1, defaultCloseBrace);
  const accountEntries = parseTopLevelEntries_(defaultBlock);

  const accounts = [];
  accountEntries.forEach(entry => {
    if (!/^@/.test(entry.key)) return;

    const accountBlock = entry.tableText;
    const accountWideText = extractNamedTable_(accountBlock, '$AccountWide');
    const tableName = accountWideText.indexOf('["sharedItems"]') >= 0 ? 'sharedItems' : 'dumpedItems';
    const itemsText = extractNamedTable_(accountWideText, tableName);
    const itemEntries = parseTopLevelEntries_(itemsText);
    const items = itemEntries.map(itemEntry => parseDumpedItemEntry_(itemEntry.tableText)).filter(Boolean);

    accounts.push({
      accountName: entry.key,
      items: items
    });
  });

  return accounts;
}

function extractNamedTable_(text, tableName) {
  const marker = `["${tableName}"]`;
  const markerIndex = text.indexOf(marker);
  if (markerIndex === -1) {
    throw new Error(`Could not find the ${tableName} table in the uploaded file.`);
  }

  const braceStart = text.indexOf('{', markerIndex);
  if (braceStart === -1) {
    throw new Error(`Could not parse the ${tableName} table.`);
  }

  const braceEnd = findMatchingBrace_(text, braceStart);
  return text.slice(braceStart + 1, braceEnd);
}

function parseTopLevelEntries_(blockText) {
  const entries = [];
  let i = 0;

  while (i < blockText.length) {
    i = skipWhitespaceAndCommas_(blockText, i);
    if (i >= blockText.length) break;

    if (blockText[i] !== '[' || blockText[i + 1] !== '"') {
      i += 1;
      continue;
    }

    const keyStart = i + 2;
    const keyEnd = findStringTerminator_(blockText, keyStart);
    const key = unescapeLuaString_(blockText.slice(keyStart, keyEnd));

    i = keyEnd + 2;
    i = skipWhitespaceAndCommas_(blockText, i);

    if (blockText[i] !== '=') {
      throw new Error(`Malformed entry near key ${key}.`);
    }

    i += 1;
    i = skipWhitespaceAndCommas_(blockText, i);

    if (blockText[i] !== '{') {
      throw new Error(`Expected a table value for key ${key}.`);
    }

    const tableStart = i;
    const tableEnd = findMatchingBrace_(blockText, tableStart);
    const tableText = blockText.slice(tableStart + 1, tableEnd);

    entries.push({ key, tableText });
    i = tableEnd + 1;
  }

  return entries;
}

function parseDumpedItemEntry_(tableText) {
  const itemName = parseLuaStringField_(tableText, 'itemName');
  if (!itemName) return null;

  return {
    name: itemName,
    accountName: parseLuaStringField_(tableText, 'accountName') || '',
    itemType: parseLuaNumberField_(tableText, 'itemType') || 0,
    itemTypeName: parseLuaStringField_(tableText, 'itemTypeName') || String(parseLuaNumberField_(tableText, 'itemType') || ''),
    quality: parseLuaNumberField_(tableText, 'quality') || 0,
    qualityName: parseLuaStringField_(tableText, 'qualityName') || String(parseLuaNumberField_(tableText, 'quality') || ''),
    trait: parseLuaStringField_(tableText, 'trait') || '',
    itemLink: parseLuaStringField_(tableText, 'itemLink') || '',
    sharedFrom: parseLuaStringField_(tableText, 'sharedFrom') || '',
    count: parseLuaNumberField_(tableText, 'count') || 0,
    firstDumpedAt: parseLuaNumberField_(tableText, 'firstDumpedAt') || 0,
    lastDumpedAt: parseLuaNumberField_(tableText, 'lastDumpedAt') || 0
  };
}

function parseLuaStringField_(text, fieldName) {
  const re = new RegExp(`\\["${escapeRegExp_(fieldName)}"\\]\\s*=\\s*"((?:\\\\.|[^"\\\\])*)"`);
  const match = re.exec(text);
  return match ? unescapeLuaString_(match[1]) : '';
}

function parseLuaNumberField_(text, fieldName) {
  const re = new RegExp(`\\["${escapeRegExp_(fieldName)}"\\]\\s*=\\s*(-?\\d+(?:\\.\\d+)?)`);
  const match = re.exec(text);
  return match ? Number(match[1]) : 0;
}

function escapeRegExp_(value) {
  return String(value).replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function unescapeLuaString_(value) {
  return String(value)
    .replace(/\\\\/g, '\\')
    .replace(/\\"/g, '"')
    .replace(/\\n/g, '\n')
    .replace(/\\r/g, '\r')
    .replace(/\\t/g, '\t');
}

function skipWhitespaceAndCommas_(text, index) {
  while (index < text.length && /[\s,]/.test(text[index])) {
    index += 1;
  }
  return index;
}

function findStringTerminator_(text, startIndex) {
  let i = startIndex;
  while (i < text.length) {
    if (text[i] === '"' && text[i - 1] !== '\\') {
      return i;
    }
    i += 1;
  }
  throw new Error('Unterminated string in uploaded file.');
}

function findMatchingBrace_(text, openIndex) {
  let depth = 0;
  let inString = false;

  for (let i = openIndex; i < text.length; i += 1) {
    const ch = text[i];
    const prev = i > 0 ? text[i - 1] : '';

    if (ch === '"' && prev !== '\\') {
      inString = !inString;
      continue;
    }

    if (inString) continue;

    if (ch === '{') depth += 1;
    if (ch === '}') {
      depth -= 1;
      if (depth === 0) return i;
    }
  }

  throw new Error('Could not match braces in uploaded file.');
}

function clearRequestedByVisuals_(range) {
  range.setBackground(null);
  range.clearNote();
}

function onSelectionChange(e) {
  if (!e || !e.range) return;
  if (isBatchUpdateInProgress_()) return;

  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const props = PropertiesService.getDocumentProperties();

  const previousSheetName = props.getProperty(LAST_HIGHLIGHTED_SHEET_KEY);
  const previousRow = Number(props.getProperty(LAST_HIGHLIGHTED_ROW_KEY) || 0);

  if (previousSheetName && previousRow > 1) {
    const previousSheet = ss.getSheetByName(previousSheetName);
    if (previousSheet && previousRow <= previousSheet.getMaxRows()) {
      const previousColumnCount = previousSheet.getName() === MASTER_SHEET_NAME ? MASTER_HEADER_ROW.length : HEADER_ROW.length;
      previousSheet.getRange(previousRow, 1, 1, previousColumnCount).setBackground(null);
    }
  }

  const range = e.range;
  const sheet = range.getSheet();
  const row = range.getRow();

  if (row <= 1) {
    props.deleteProperty(LAST_HIGHLIGHTED_SHEET_KEY);
    props.deleteProperty(LAST_HIGHLIGHTED_ROW_KEY);
    return;
  }

  const columnCount = sheet.getName() === MASTER_SHEET_NAME ? MASTER_HEADER_ROW.length : HEADER_ROW.length;
  sheet.getRange(row, 1, 1, columnCount).setBackground('#fff2cc');

  props.setProperty(LAST_HIGHLIGHTED_SHEET_KEY, sheet.getName());
  props.setProperty(LAST_HIGHLIGHTED_ROW_KEY, String(row));
}

function onEdit(e) {
  if (!e || !e.range) return;

  const range = e.range;
  const sheet = range.getSheet();
  if (range.getRow() === 1) return;

  const isMaster = sheet.getName() === MASTER_SHEET_NAME;
  const requestedByCol = isMaster ? MASTER_COL_REQUESTED_BY : COL_REQUESTED_BY;

  if (range.getColumn() === requestedByCol) {
    withDocumentLock_(function() {
      const value = String(range.getValue() || '').trim();
      syncRequestedByFromEdit_(sheet, range.getRow(), value);
    });
    return;
  }

  if (isBatchUpdateInProgress_()) return;
  if (isMaster) return;

  tryWithDocumentLock_(function() {
    if (isBatchUpdateInProgress_()) return;
    rebuildMasterSheet_();
    activateMasterSheet_();
  });
}

function onChange(e) {
  if (!e) return;
  if (isBatchUpdateInProgress_()) return;

  tryWithDocumentLock_(function() {
    if (isBatchUpdateInProgress_()) return;

    const ss = SpreadsheetApp.getActiveSpreadsheet();
    const activeSheet = ss.getActiveSheet();
    if (!activeSheet || activeSheet.getName() === MASTER_SHEET_NAME) return;

    const changeType = String(e.changeType || '');
    const shouldRebuild =
      changeType === 'INSERT_ROW' ||
      changeType === 'REMOVE_ROW' ||
      changeType === 'INSERT_GRID' ||
      changeType === 'REMOVE_GRID' ||
      changeType === 'EDIT';

    if (!shouldRebuild) return;

    rebuildMasterSheet_();
    activateMasterSheet_();
  });
}

function syncRequestedByFromEdit_(sheet, rowIndex, value) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const isMaster = sheet.getName() === MASTER_SHEET_NAME;

  if (isMaster) {
    const sourceSheetName = String(sheet.getRange(rowIndex, MASTER_COL_SOURCE_SHEET).getValue() || '').trim();
    const syncKey = String(sheet.getRange(rowIndex, MASTER_COL_SYNC_KEY).getValue() || '').trim();
    if (!sourceSheetName || !syncKey) return;

    const sourceSheet = ss.getSheetByName(sourceSheetName);
    if (!sourceSheet) return;

    const sourceRow = findRowBySyncKey_(sourceSheet, syncKey, false);
    if (sourceRow > 0) {
      const targetRange = sourceSheet.getRange(sourceRow, COL_REQUESTED_BY);
      const currentValue = String(targetRange.getValue() || '').trim();

      if (currentValue !== value) {
        targetRange.setValue(value);
        clearRequestedByVisuals_(targetRange);
      }
    }
  } else {
    const syncKey = String(sheet.getRange(rowIndex, COL_SYNC_KEY).getValue() || '').trim();
    if (!syncKey) return;

    const master = getOrCreateMasterSheet_();
    const masterRow = findRowBySyncKey_(master, syncKey, true);
    if (masterRow > 0) {
      const targetRange = master.getRange(masterRow, MASTER_COL_REQUESTED_BY);
      const currentValue = String(targetRange.getValue() || '').trim();

      if (currentValue !== value) {
        targetRange.setValue(value);
        clearRequestedByVisuals_(targetRange);
      }
    }
  }
}

function findRowBySyncKey_(sheet, syncKey, isMaster) {
  const col = isMaster ? MASTER_COL_SYNC_KEY : COL_SYNC_KEY;
  const lastRow = sheet.getLastRow();
  if (lastRow < 2) return -1;

  const values = sheet.getRange(2, col, lastRow - 1, 1).getValues();
  for (let i = 0; i < values.length; i++) {
    if (String(values[i][0] || '').trim() === syncKey) {
      return i + 2;
    }
  }
  return -1;
}

function safeHideColumn_(sheet, column) {
  try {
    sheet.hideColumns(column);
  } catch (err) {}
}

function setBatchUpdateInProgress_(inProgress) {
  const props = PropertiesService.getDocumentProperties();
  props.setProperty(BATCH_UPDATE_FLAG_KEY, inProgress ? '1' : '0');
}

function isBatchUpdateInProgress_() {
  const props = PropertiesService.getDocumentProperties();
  return props.getProperty(BATCH_UPDATE_FLAG_KEY) === '1';
}
