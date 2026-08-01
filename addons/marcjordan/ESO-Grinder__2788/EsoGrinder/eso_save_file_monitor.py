"""

"""

import argparse
import collections
import filecmp
import logging
from pathlib import Path
import os
import signal
from slpp import slpp as lua
try:
    from sqlite3 import dbapi2 as sqlite
except ImportError:
    from pysqlite2 import dbapi2 as sqlite
import sys
import threading
import time
import traceback
from watchdog.observers import Observer
from watchdog.events import PatternMatchingEventHandler

################################################################################
from utils import MyThread

################################################################################
_g_logger = logging.getLogger()
# _g_logger.setLevel(logging.DEBUG)
if False:
    _g_logger.debug = print
    _g_logger.info = print
    _g_logger.exception = print

################################################################################
if 'linux' == sys.platform or 'linux2' == sys.platform:
    _PLATFORM = 'linux'
elif 'win32' == sys.platform:
    _PLATFORM = 'windows'
else:
    raise OSError('%s platform not supported' % sys.platform)

_TAB_STRING = '    '
_ESO_ADDON_SAVE_FILE_PATH_DEFAULT = \
    Path('C:/Users/marc/Documents/Elder Scrolls Online/live/SavedVariables/EsoGrinder.lua')
_previous_snapshot_save = ''
_monitor_poll_count = 0

_PREVIOUS_FILE_NAME_DEFAULT = 'temp_previous'

_DB_FILE_NAME_DEFAULT = 'eso_save_file_monitor.db'
_DB_FILE_NAME_NEW_DEFAULT = 'eso_save_file_monitor_new.db'

_SAVED_VARIABLES_NAME_DEFAULT = 'EsoGrinderSavedVariables'

_ESO_AT_PLAYER_NAME_DEFAULT = 'Gullyable'

_ESO_ADDON_LOOT_VAR_NAME = 'loot_save'

_LOGGING_FORMATTER_DEFAULT = "'%(asctime)s %(levelname)s> %(message)s'"

_POLLING_INTERVAL_DEFAULT = 0.0

_g_sigint_signal = False

_EXIT_STRING = 'Press Ctrl-C to exit.'


################################################################################
class EsoSaveFileMonError(Exception):
    """

    """
    pass


################################################################################
def _arg_parse():
    """
    Parse command line arguments.
    """
    parser = argparse.ArgumentParser()

    parser.add_argument(
        '-a', '--eso_at_player_name',
        default=_ESO_AT_PLAYER_NAME_DEFAULT,
        dest='eso_at_player_name',
        help='ESO @PlayerName. Default = %s' % (str(_ESO_AT_PLAYER_NAME_DEFAULT)),
        required=False,
        type=str)

    parser.add_argument(
        '-b', '--database_file',
        default=_DB_FILE_NAME_DEFAULT,
        dest='database_file',
        help='Database file. Default = %s.' % (str(_DB_FILE_NAME_DEFAULT)),
        required=False,
        type=str)

    if False:
        parser.add_argument(
            '-c', '--convert_to_current_db',
            default=_DB_FILE_NAME_DEFAULT + '_new',
            dest='convert_to_current_db',
            help='Convert the specified database to the current version. Default = %s.' % (str(_DB_FILE_NAME_NEW_DEFAULT)),
            required=False,
            type=str)

    logging_levels = [0, 10, 20, 30, 40, 50]
    parser.add_argument(
        '-l', '--logging_level',
        type=int,
        default=20,
        dest='logging_level',
        help='Logging level. Default = 20 INFO. Use 10 for DEBUG.',
        required=False)

    parser.add_argument(
        '-f', '--eso_addon_save_file_path',
        default=_ESO_ADDON_SAVE_FILE_PATH_DEFAULT,
        dest='eso_addon_save_file_path',
        help='Path to ESO save file to be monitored. Default = \"%s\".' % (str(_ESO_ADDON_SAVE_FILE_PATH_DEFAULT)),
        required=False,
        type=str)

    parser.add_argument(
        '-p', '--polling_interval',
        default=0.0,
        dest='polling_interval',
        help='Enable old-style time.sleep() polling of ESO save file. If 0.0 then disabled. Default = 0.0.',
        required=False,
        type=float)

    parser.add_argument(
        '-t', '--previous_file',
        default=_PREVIOUS_FILE_NAME_DEFAULT,
        dest='previous_file',
        help='File for saving previous addon save file. Default = %s.' % (str(_PREVIOUS_FILE_NAME_DEFAULT)),
        required=False,
        type=str)

    args = parser.parse_args()

    return args


################################################################################
class Loot(object):
    """

    """
    _DB_ADD_LOOT = 'name, quantity, type, quality, status, value, mm, ttc, time, ' \
                   'player_name, x, y, location, zone, subzone, player_status'

    def __init__(self):
        self.name = ''
        self.quantity = ''
        self.typ = ''
        self.quality = ''
        self.status = ''
        self.value = ''
        self.mm = ''
        self.ttc = ''
        self.time = ''
        self.player_name = ''
        self.x = ''
        self.y = ''
        self.location = ''
        self.zone = ''
        self.subzone = ''
        self.player_status = ''
        self.egr_db_version = ''
        self.player_location = ''

    def get_db_columns_string(self):
        """

        :return:
        """
        return self._DB_ADD_LOOT

    def get_db_values_string(self):
        """

        :return:
        """
        s = '"%s"' % self.name + ','
        s += '"%s"' % self.quantity + ','
        s += '"%s"' % self.typ + ','
        s += '"%s"' % self.quality + ','
        s += '"%s"' % self.status + ','
        s += '"%s"' % self.value + ','
        s += '"%s"' % self.mm + ','
        s += '"%s"' % self.ttc + ','
        s += '"%s"' % self.time + ','
        s += '"%s"' % self.player_name + ','
        s += '"%s"' % self.x + ','
        s += '"%s"' % self.y + ','
        s += '"%s"' % self.location + ','
        s += '"%s"' % self.zone + ','
        s += '"%s"' % self.subzone + ','
        s += '"%s"' % self.player_status
        return s


################################################################################
class _Loot_3_0_0_wip(object):
    """

    """
    _DB_ADD_LOOT = 'name, quantity, type, quality, status, value, mm, ttc, time, ' \
                   'player_name, x, y, location, zone, subzone, player_status'

    def __init__(self):
        self.name = ''
        self.quantity = ''
        self.typ = ''
        self.quality = ''
        self.status = ''
        self.value = ''
        self.mm = ''
        self.ttc = ''
        self.time = ''
        self.player_name = ''
        self.x = ''
        self.y = ''
        self.location = ''
        self.zone = ''
        self.subzone = ''
        self.player_status = ''
        self.egr_db_version = ''
        self.player_location = ''
        self.egr_db_version = ''
        self.player_location = ''

    def get_db_columns_string(self):
        """

        :return:
        """
        return self._DB_ADD_LOOT

    def get_db_values_string(self):
        """

        :return:
        """
        s = '"%s"' % self.name + ','
        s += '"%s"' % self.quantity + ','
        s += '"%s"' % self.typ + ','
        s += '"%s"' % self.quality + ','
        s += '"%s"' % self.status + ','
        s += '"%s"' % self.value + ','
        s += '"%s"' % self.mm + ','
        s += '"%s"' % self.ttc + ','
        s += '"%s"' % self.time + ','
        s += '"%s"' % self.player_name + ','
        s += '"%s"' % self.x + ','
        s += '"%s"' % self.y + ','
        s += '"%s"' % self.location + ','
        s += '"%s"' % self.zone + ','
        s += '"%s"' % self.subzone + ','
        s += '"%s"' % self.player_status + ','
        s += '"%s"' % self.egr_db_version + ','
        s += '"%s"' % self.player_location
        return s


################################################################################
class MyHandler(PatternMatchingEventHandler):
    def __init__(self, **kwargs):

        try:
            super(MyHandler, self).__init__(
                patterns=kwargs['patterns'],
                ignore_patterns=kwargs['ignore_patterns'],
                ignore_directories=kwargs['ignore_directories'])
            self.monitor_thread = kwargs['monitor_thread']
        except Exception as exc:
            s = traceback.format_exc()
            pass

    def on_any_event(self, event):
        # _g_logger.debug('on_any_event type(event) =  %s' % str(type(event)))
        pass

    def on_created(self, event):
        _g_logger.error('on_created type(event) =  %s' % str(type(event)))

        # if type(FileCreatedEvent) == type(event):
        #    self.monitor_thread.save_file_mod_watchdog_event.set()
        pass

    def on_deleted(self, event):
        """
        For some reason this always gets called immediately after starting the Observer.
        :param event:
        :return:
        """
        _g_logger.error('on_deleted type(event) =  %s' % str(type(event)))
        pass

    def on_modified(self, event):
        if False:
            _g_logger.debug('on_modified event =  %s' % str(event))
            _g_logger.debug('on_modified type(event) =  %s' % str(type(event)))
            _g_logger.debug('on_modified type(event.event_type) =  %s' % str(type(event.event_type)))
            _g_logger.debug('on_modified event.event_type =  %s' % str(event.event_type))
            _g_logger.debug('on_modified event.is_directory =  %s' % str(event.is_directory))

            _g_logger.debug('self.monitor_thread.save_file_mod_watchdog_file_name =  %s' % str(self.monitor_thread.save_file_mod_watchdog_file_name))
            _g_logger.debug('os.path.basename(event.src_path) =  %s' % str(os.path.basename(event.src_path)))

        if event.is_directory:
            return

        if 'modified' == event.event_type:
            if os.path.basename(event.src_path) == self.monitor_thread.save_file_mod_watchdog_file_name:
                self.monitor_thread.save_file_mod_watchdog_event.set()

    def on_moved(self, event):
        _g_logger.error('on_moved type(event) =  %s' % str(type(event)))
        pass


################################################################################
class MonitorThread(MyThread):
    """

    """
    _SAVED_VARIABLES_NAME_STRINGS = [
        _SAVED_VARIABLES_NAME_DEFAULT+' =',
        _SAVED_VARIABLES_NAME_DEFAULT+'=',
    ]

    def __init__(
            self,
            eso_at_player_name=_ESO_AT_PLAYER_NAME_DEFAULT,
            eso_addon_save_file_path=_ESO_ADDON_SAVE_FILE_PATH_DEFAULT,
            database_file=_DB_FILE_NAME_DEFAULT,
            previous_file=_PREVIOUS_FILE_NAME_DEFAULT,
            polling_interval=_POLLING_INTERVAL_DEFAULT):
        super(MonitorThread, self).__init__()
        self._eso_at_player_name = eso_at_player_name
        self._eso_addon_save_file_path = eso_addon_save_file_path
        self._database_file = database_file
        self._previous_file = previous_file
        self._polling_interval = polling_interval

        if 0.0 < polling_interval:
            self.thread_method = self._thread_method_poll
        else:
            self.thread_method = self._thread_method_watchdog

        self._db_conn = None
        self._prefix = ''
        self._monitor_poll_count = 0
        self.savefile_process_delta_count = 0
        self._first_process_delta = True

        if not os.path.isfile(self._previous_file):
            open(self._previous_file, 'w').close()

        self._db_build_tables = self._db_build_tables_2_0_0

        if not os.path.isfile(self._database_file):
            conn = self._db_create(self._database_file)
            self._db_build_tables(conn)

        self.save_file_mod_watchdog_event = threading.Event()
        self.save_file_mod_watchdog_event.clear()
        self.save_file_mod_watchdog_file_name = os.path.basename(self._eso_addon_save_file_path)
        self._save_file_mod_watchdog_event_handler = MyHandler(
            patterns=[self.save_file_mod_watchdog_file_name],
            ignore_patterns=[],
            ignore_directories=True,
            monitor_thread=self)
        if 'windows' == _PLATFORM:
            self.save_file_mod_watchdog_src_path = os.path.dirname(self._eso_addon_save_file_path).replace('/', '\\')
        else:
            self.save_file_mod_watchdog_src_path = os.path.dirname(self._eso_addon_save_file_path).replace('\\', '/')
        self._save_file_mod_watchdog_observer = Observer()
        self._save_file_mod_watchdog_observer.schedule(
            self._save_file_mod_watchdog_event_handler,
            path=self.save_file_mod_watchdog_src_path,
            recursive=False)

        # This was to support the first, early dev change in db design.
        # self.convert_old_to_new()

    ############################################################################
    def convert_to_3_0_0_wip(self):
        _g_logger.debug('convert_to_3_0_0_wip')
        old_conn = self._db_open(_DB_FILE_NAME_DEFAULT)
        old_curs = old_conn.cursor()

        db_3_0_0_file_name = self._db_open(_DB_FILE_NAME_DEFAULT + '3_0_0')
        new_conn = self._db_open(db_3_0_0_file_name)
        self._db_build_tables_3_0_0(new_conn)
        new_curs = new_conn.cursor()

        for i in range(2000):
            old_curs.execute("SELECT * FROM loot where id = %d"%i)
            old_row = old_curs.fetchone()
            if old_row is not None:
                print(old_row)
                data = old_row[1].replace('\\t', '\t').split('\t')
                loot = Loot()
                loot.name = data[0]
                loot.quantity = data[1]
                loot.typ = data[2]
                loot.quality = data[3]
                loot.status = data[4]
                loot.value = data[5]
                loot.mm = data[6]
                loot.ttc = data[7]
                loot.time = data[8]
                loot.player_name = data[9]
                loot.x = data[10]
                loot.y = data[11]
                loot.location = data[12]
                loot.zone = data[13]
                loot.subzone = data[14]
                loot.player_status = data[15]
                self._db_add_loot2(new_conn, loot)

        new_conn.commit()

    ############################################################################
    def _db_add_loot(self, db_conn, loot_string):
        db_curs = db_conn.cursor()

        loot = self._get_loot_obj_from_data_string_2_0_0(loot_string)
        s = 'INSERT INTO loot (%s) VALUES (%s)' % (loot.get_db_columns_string(), loot.get_db_values_string())

        e = None
        try:
            db_curs.execute(s)
        except sqlite.OperationalError as exc:
            e = exc
            _g_logger.exception('Failed to insert data into database: %s' % s)
        if e is not None:
            raise e

    ############################################################################
    @staticmethod
    def _db_build_tables_2_0_0(db_conn):
        db_curs = db_conn.cursor()
        db_curs.execute("CREATE TABLE IF NOT EXISTS loot (\
                        id INTEGER PRIMARY KEY,\
                        name TEXT,\
                        quantity TEXT,\
                        type TEXT,\
                        quality TEXT,\
                        status TEXT,\
                        value TEXT,\
                        mm TEXT,\
                        ttc TEXT,\
                        time TEXT,\
                        player_name TEXT,\
                        x TEXT,\
                        y TEXT,\
                        location TEXT,\
                        zone TEXT,\
                        subzone TEXT,\
                        player_status TEXT)")

    ############################################################################
    @staticmethod
    def _db_build_tables_3_0_0(db_conn):
        db_curs = db_conn.cursor()
        db_curs.execute("CREATE TABLE IF NOT EXISTS loot (\
                        id INTEGER PRIMARY KEY,\
                        name TEXT,\
                        quantity TEXT,\
                        type TEXT,\
                        quality TEXT,\
                        status TEXT,\
                        value TEXT,\
                        mm TEXT,\
                        ttc TEXT,\
                        time TEXT,\
                        player_name TEXT,\
                        x TEXT,\
                        y TEXT,\
                        location TEXT,\
                        zone TEXT,\
                        subzone TEXT,\
                        player_status TEXT,\
                        egr_db_version TEXT,\
                        player_location TEXT\
                        )")

    ############################################################################
    @staticmethod
    def _db_create(database_file):
        return sqlite.connect(database_file)

    ############################################################################
    @staticmethod
    def _db_fetchall(db_conn):
        db_curs = db_conn.cursor()
        db_curs.execute("SELECT * FROM loot")
        data = db_curs.fetchall()
        return data

    ############################################################################
    @staticmethod
    def _db_open(database_file):
        return sqlite.connect(database_file)

    ############################################################################
    def _get_loot_dict_from_lua_string(self, s):
        lua_table_dict = lua.decode(s)
        loot_dict = lua_table_dict['Default']['@%s' % self._eso_at_player_name]['$AccountWide'][_ESO_ADDON_LOOT_VAR_NAME]
        loot_tuple_list = sorted(loot_dict.items(), key=lambda kv: kv[0])
        loot_dict = collections.OrderedDict(loot_tuple_list)
        return loot_dict

    ############################################################################
    @staticmethod
    def _get_loot_obj_from_data_string_2_0_0(data_string):
        data = data_string.replace('\\t', '\t').split('\t')
        loot = Loot()
        # todo: guard against malformed strings
        loot.name = data[0]
        loot.quantity = data[1]
        loot.typ = data[2]
        loot.quality = data[3]
        loot.status = data[4]
        loot.value = data[5]
        loot.mm = data[6]
        loot.ttc = data[7]
        loot.time = data[8]
        loot.player_name = data[9]
        loot.x = data[10]
        loot.y = data[11]
        loot.location = data[12]
        loot.zone = data[13]
        loot.subzone = data[14]
        loot.player_status = data[15]
        return loot

    ############################################################################
    @staticmethod
    def _get_loot_obj_from_data_string_3_0_0_wip(data_string):
        data = data_string.replace('\\t', '\t').split('\t')
        loot = Loot()
        # todo: guard against malformed strings
        loot.name = data[0]
        loot.quantity = data[1]
        loot.typ = data[2]
        loot.quality = data[3]
        loot.status = data[4]
        loot.value = data[5]
        loot.mm = data[6]
        loot.ttc = data[7]
        loot.time = data[8]
        loot.player_name = data[9]
        loot.x = data[10]
        loot.y = data[11]
        loot.location = data[12]
        loot.zone = data[13]
        loot.subzone = data[14]
        loot.player_status = data[15]
        loot.egr_db_version = data[16]
        loot.player_location = data[17]
        return loot

    ############################################################################
    def process_delta(self):
        if self._first_process_delta:
            self._first_process_delta = False
            _g_logger.debug('%d  Initial save file check:' % self.savefile_process_delta_count)
        else:
            _g_logger.debug('%d  Processing save file mod event:' % self.savefile_process_delta_count)
        self.savefile_process_delta_count += 1

        try:
            f = open(self._eso_addon_save_file_path, 'r')
        except OSError:
            _g_logger.debug('    Save file may be open in ESO. This is okay.')
            _g_logger.debug('Press Ctrl-C to exit.')
            return

        new_file_string = f.read()
        f.close()
        ok = False
        temp_split = None
        for saved_variable_name in self._SAVED_VARIABLES_NAME_STRINGS:
            if saved_variable_name in new_file_string:
                temp_split = new_file_string.replace('\n', '').split(saved_variable_name)
                ok = True
                break
        if not ok:
            raise EsoSaveFileMonError('Invalid input file')
        new_lua_table_string = temp_split[1]
        new_loot_dict = self._get_loot_dict_from_lua_string(new_lua_table_string)

        f = open(self._previous_file, 'r')
        prev_file_string = f.read()
        f.close()
        db_conn = None
        if 0 == len(prev_file_string):
            count = 0
            for k, v in new_loot_dict.items():
                count += 1
                v = v.replace('"', '')
                _g_logger.debug('    %s' % v)
                if db_conn is None:
                    db_conn = self._db_open(self._database_file)
                self._db_add_loot(db_conn, v)
            if db_conn is not None:
                db_conn.commit()
                db_conn.close()
            _g_logger.debug('    %d new loot item(s) added to the database. This is okay.' % count)
            f = open(self._previous_file, 'w')
            f.write(new_file_string)
            f.close()
            return

        ok = False
        for saved_variable_name in self._SAVED_VARIABLES_NAME_STRINGS:
            if saved_variable_name in prev_file_string:
                temp_string = prev_file_string.replace('\n', '')
                temp_split = temp_string.split(saved_variable_name)
                ok = True
                break
        if not ok:
            raise EsoSaveFileMonError('Invalid input file')
        prev_lua_table_string = temp_split[1]
        prev_loot_dict = self._get_loot_dict_from_lua_string(prev_lua_table_string)

        db_conn = None
        count = 0
        for k, v in new_loot_dict.items():
            if k in prev_loot_dict and v == prev_loot_dict[k]:
                pass
            else:
                count += 1
                v = v.replace('"', '')
                _g_logger.debug('    %s' % v)
                if db_conn is None:
                    db_conn = self._db_open(self._database_file)
                self._db_add_loot(db_conn, v)
        if db_conn is not None:
            db_conn.commit()
            db_conn.close()
        _g_logger.debug('    %d new loot item(s) added to the database. This is okay.' % count)
        _g_logger.debug('Press Ctrl-C to exit.')

        f = open(self._previous_file, 'w')
        f.write(new_file_string)
        f.close()

    ############################################################################
    def _thread_method_poll(self):
        """
        Original, inefficient polling.

        :return:
        """
        self._started_event.set()
        _g_logger.debug('Thread started.')

        self.process_delta()

        while True:
            if self._stop:
                break

            try:
                if filecmp.cmp(self._eso_addon_save_file_path, self._previous_file, shallow=False):
                    pass
                else:
                    self.process_delta()
                self._monitor_poll_count += 1
                time.sleep(self._polling_interval)
            except Exception as exc:
                _g_logger.exception('Thread failed call to self.thread_method()')
                break

        _g_logger.debug('Thread stopped.')
        self._stopped_event.set()

    ############################################################################
    def _thread_method_watchdog(self):
        """
        Watchdog polling.
        :return:
        """
        self.process_delta()

        self.save_file_mod_watchdog_event.clear()
        self._save_file_mod_watchdog_observer.start()

        _g_logger.debug('Thread started.')
        self._started_event.set()
        while True:
            if self._stop:
                self._save_file_mod_watchdog_observer.stop()
                break

            try:
                event_found = self.save_file_mod_watchdog_event.wait(2.0)
                # _g_logger.debug('event_found = %s' % str(event_found))
                if event_found:
                    self.save_file_mod_watchdog_event.clear()
                    self.process_delta()
            except Exception as exc:
                _g_logger.exception('Thread failed call to self.thread_method()')
                break

        _g_logger.debug('Thread stopped.')
        self._stopped_event.set()


################################################################################
def main():
    """
    :return:
    """

    args = _arg_parse()

    logging.basicConfig(format=format('%(asctime)s %(levelname)s> %(message)s'))
    _g_logger.setLevel(args.logging_level)

    _g_logger.info('ESO addon save file = %s' % args.eso_addon_save_file_path)
    _g_logger.info('Database file       = %s' % os.path.abspath(args.database_file))

    thread = MonitorThread(
        eso_addon_save_file_path=args.eso_addon_save_file_path,
        database_file=args.database_file,
        previous_file=args.previous_file,
        eso_at_player_name=args.eso_at_player_name,
        polling_interval=args.polling_interval)
    thread.start(timeout=5.0)

    def _sigint_signal_handler(sig, frame):
        global _g_sigint_signal
        # todo: can do a threading.Event here?
        _g_sigint_signal = True

    signal.signal(signal.SIGINT, _sigint_signal_handler)
    _g_logger.debug('ESO addon save file access activity events reported by the file system result in')
    _g_logger.debug('the following benign watchdog events:')
    _g_logger.debug('    "0 new loot items(s) added to the database. This is okay."')
    _g_logger.debug('    "Save file may be open in ESO. This is okay.')
    _g_logger.info('Use the -l 10 option to debug monitor stream events.')
    _g_logger.info('Open the database file with a viewer as read-only to extract/view data in real-time.')
    _g_logger.info('Press Ctrl-C to exit.')
    _rc = None
    while True:
        if thread.is_stopped():
            _rc = -1
            break
        if _g_sigint_signal:
            thread.stop(timeout=5.0)
            _rc = 0
            break
        time.sleep(0.200)

    _g_logger.debug('savefile_process_delta_count = %s' % thread.savefile_process_delta_count)
    _g_logger.debug('Exit.')
    return _rc


################################################################################
if __name__ == '__main__':
    rc = main()
    sys.exit(rc)
