import logging
import os, gzip, shutil,sys
from functools import wraps

import os, gzip, shutil

def rotate_log_compression(log_file_path, threshold=100*1024*1024, backup_count=7):
    """
    rotate_log_compression
    ----------------------
    
    This function is for use instead of RotatingFileHandle, which will compresses the log files upon rotation.

    In Windows, less so Linux I believe, the aim of this function is to be run at application startup,
    and if the threshold exceeds the threshold, rotate and compress to avoid file locks.

    Useage:
    -------
        rotate_log_compression(log_file_path='/home/user/logs', threshold=100*1024*1024, backup_count=7)

    Args:
    -----
        log_file_path: str
            Where you want your log files to be
        threshold: int
            default=100*1024*1024 
            My way of expressing 100MB. So files greater than 100MB will be rotated
        backup_count: int
            default=7
            Number of gzip files to keep in rotation
    """
        
    if os.path.exists(log_file_path) and os.path.getsize(log_file_path) > threshold:
        
        # Step 1: Increment existing backups
        for i in range(backup_count, 0, -1):
            src = f"{log_file_path}.{i}"
            dst = f"{log_file_path}.{i+1}"
            if os.path.exists(src):
                os.rename(src, dst)
                # Optional: Compress during rotation
                with open(dst, 'rb') as f_in, gzip.open(f"{dst}.gz", 'wb') as f_out:
                    shutil.copyfileobj(f_in, f_out)
                os.remove(dst)
        
        # Step 2: Rotate the current log file
        if os.path.exists(log_file_path):
            os.rename(log_file_path, f"{log_file_path}.1")
            # Optional: Compress the newly rotated file
            with open(f"{log_file_path}.1", 'rb') as f_in, gzip.open(f"{log_file_path}.1.gz", 'wb') as f_out:
                shutil.copyfileobj(f_in, f_out)
            os.remove(f"{log_file_path}.1")
        
        # Step 3: Manage backup count - Delete the oldest if it exceeds the limit
        oldest_backup = f"{log_file_path}.{backup_count}"
        if os.path.exists(f"{oldest_backup}.gz"):
            os.remove(f"{oldest_backup}.gz")


# Initial log file paths
# defaults to root directory/log/jplib.log
log_path: str = os.path.join(os.path.abspath(os.curdir), 'log')
if not os.path.exists(log_path):
    os.makedirs(log_path, exist_ok=True)
log_file_path: str = os.path.join(log_path, 'jplib.log')

class JPLogs:
    '''
    JPLogs
    ------

    This class sets up named loggers, avoiding the root logger.

    This provides control for file handlers, and stream (std.out/error) handlers.

    While the std.out and file handling are optional (but you should want one of them), the std.error handling is on by default. Will be monitoring this closely.

    Args:
    -----
        level: logging level, default: logging.INFO
        log_to_stdout: bool default: False
        log_to_file: bool default: False
        log_file: str default: log_file_path (variable in this script)

    Useage:
    -------
        logger = JPLogs(level=logging.INFO,log_to_stdout=False,log_to_file=True,log_file=log_file_path) # Logs to file
        logger = JPLogs(level=logging.INFO,log_to_stdout=True,log_to_file=False,log_file=log_file_path) # Logs to stdout
        logger = JPLogs(level=logging.INFO,log_to_stdout=True,log_to_file=True,log_file=log_file_path) # Logs to file and stdout
    '''
    def __init__(self, name=__name__,
                 level=logging.INFO,
                 log_to_stdout=False,
                 log_to_file=False,
                 log_file=log_file_path) -> None:
        
        self.name: str = name
        self.level: int = level
        # Set up logger
        self.logger: logging.Logger = logging.getLogger(self.name)
        self.logger.setLevel(self.level)
        self.logger.propagate = False
                     
        # Set up the file and stream handlers
        if log_to_stdout:
            # Ensure no other self.logger handlers are StreamHandlers
            for handler in self.logger.handlers[:]:
                if isinstance(handler, logging.StreamHandler):
                    self.logger.removeHandler(handler)
            stream_handler_config = {
                'init': {'stream': sys.stdout},
                'formatter': {'fmt': '%(asctime)s %(levelname)s: %(message)s', 'datefmt': '%d-%b-%y %H:%M:%S'},
                'level': logging.INFO
            }
            self.add_handler(logging.StreamHandler, stream_handler_config)

        if log_to_file:
            file_handler_config = {
                'init': {'filename': log_file},
                'formatter': {'fmt': '%(asctime)s %(levelname)s: %(message)s', 'datefmt': '%d-%b-%y %H:%M:%S'}
            }
            self.add_handler(logging.FileHandler, file_handler_config)
            
        # Handler for stderr (WARNING, ERROR, CRITICAL)
        stderr_handler_config = {
            'init': {'stream': sys.stderr},
            'formatter': {'fmt': '%(asctime)s %(levelname)s: %(message)s', 'datefmt': '%d-%b-%y %H:%M:%S'},
            'level': logging.WARNING
        }
        self.add_handler(logging.StreamHandler, stderr_handler_config)
            
    def add_handler(self, handler_class, handler_config):
        handler_exists = any(isinstance(handler, handler_class) for handler in self.logger.handlers)
        if not handler_exists:
            handler = handler_class(**handler_config['init'])
            handler.setLevel(handler_config.get('level', self.level))
            formatter = logging.Formatter(**handler_config['formatter'])
            handler.setFormatter(formatter)
            self.logger.addHandler(handler)
    
    def info(self, message, name=None):
        msg: str = f'{name}: {message}' if name is not None else message
        self.logger.info(msg)

    def error(self, message, name=None):
        msg: str = f'{name}: {message}' if name is not None else message
        self.logger.error(msg)

    def warning(self, message, name=None):
        msg: str = f'{name}: {message}' if name is not None else message
        self.logger.warning(msg)

    def critical(self, message, name=None):
        msg: str = f'{name}: {message}' if name is not None else message
        self.logger.critical(msg)

def my_logger(orig_func):
    '''
    Simple wrapper function for functions/methods. I have this set to log to file, and not stdout. 

    Useage:
    -------
        @my_logger
        def function_of_sorts(...):

    Returns:
        Information about the method/function called and reports whether it completes or any exceptions occured
    '''
    log_instance = IMP3Logs(name=orig_func.__name__, log_to_file=True, log_to_stdout=False)
    @wraps(orig_func)
    def wrapper(*args, **kwargs):
        log_instance.info(f'{orig_func.__name__} Started')
        try:
            value = orig_func(*args, **kwargs)
            log_instance.info(f'Completed: {orig_func.__name__} Ran without error')
        except Exception as exy:
            log_instance.warning(f'Exception occurred: {exy}')
            raise exy
        return value
    return wrapper
