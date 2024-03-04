import logging
import os, gzip, shutil,sys
from functools import wraps

import os, gzip, shutil

def rotate_log_compression(log_file_path, threshold=100*1024*1024, backup_count=7):
    """
    An extension of RotatingFileHandler that compresses the log files upon rotation.
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


# Initial configuration call
log_path: str = os.path.join(os.path.abspath(os.curdir), 'log')
if not os.path.exists(log_path):
    os.makedirs(log_path, exist_ok=True)
log_file_path: str = os.path.join(log_path, 'jplib.log')

class IMP3Logs:
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

        if log_to_stdout:
            for handler in self.logger.handlers[:]:
                if isinstance(handler, logging.StreamHandler):
                    self.logger.removeHandler(handler)
            stream_handler_config = {
                'init': {'stream': sys.stdout},
                'formatter': {'fmt': '%(asctime)s %(levelname)s: %(message)s', 'datefmt': '%d-%b-%y %H:%M:%S'},
                'level': logging.INFO
            }
            self.add_handler(logging.StreamHandler, stream_handler_config)

        # Set up the file and stream handlers
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

def my_logger(orig_func):
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