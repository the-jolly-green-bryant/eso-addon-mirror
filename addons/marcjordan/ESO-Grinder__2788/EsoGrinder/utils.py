"""

"""

import logging
import sys
import threading
import time

################################################################################
_g_logger = logging.getLogger()
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


################################################################################
class MyThreadError(Exception):
    pass


class MyThreadStopError(MyThreadError):
    pass


class MyThreadStartError(MyThreadError):
    pass


################################################################################
class MyThread(object):
    _START_SLEEP_TIME = 0.3
    _STOP_SLEEP_TIME = 0.3

    ############################################################################
    def __init__(self, ):
        self._stop = False
        self._started_event = threading.Event()
        self._started_event.clear()
        self._stopped_event = threading.Event()
        self._stopped_event.clear()
        self._thread = None
        self._lock = threading.Lock()

    ############################################################################
    def is_stopped(self):
        return self._stopped_event.is_set()

    ############################################################################
    def start(self, timeout=None):
        if self._started_event.is_set():
            raise MyThreadStartError('Already started.')

        self._thread = threading.Thread(target=self.thread_method, daemon=True)
        self._thread.start()
        if timeout is None:
            return
        event_found = self._started_event.wait(timeout=timeout)
        if not event_found:
            raise MyThreadStopError('Timeout starting thread')

    ############################################################################
    def stop(self, timeout=5.0):
        if not self._started_event.is_set():
            raise MyThreadStopError('Not started.')
        self._stop = True
        event_found = self._stopped_event.wait(timeout=timeout)
        self._thread = None
        self._stopped_event.clear()
        self._started_event.clear()
        if not event_found:
            raise MyThreadStopError('Timeout stopping thread')

    ############################################################################
    def thread_method(self):
        """
        Overload this method.
        :return: None
        """
        self._started_event.set()
        _g_logger.debug('Thread started.')
        while True:
            if self._stop:
                break

            try:
                pass # do something
            except Exception as exc:
                _g_logger.exception('Thread failed call to self.thread_method()')
                break

        _g_logger.debug('Thread stopped.')
        self._stopped_event.set()
