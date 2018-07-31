import time
import logging
import psutil
from logging.config import dictConfig

log_config = {
    'version': 1,
    'formatters': {
        'f': {
            'format': "%(asctime)s-[%(filename)s:%(lineno)d][%(levelname)s] - %(message)s"
        },
    },
    'handlers': {
        'std_h': {
            'class': 'logging.StreamHandler',
            'formatter': 'f',
            'stream': 'ext://sys.stdout',
            'level': 'DEBUG',
        },
        'file_h': {
            'class': 'logging.handlers.RotatingFileHandler',
            'formatter': 'f',
            'filename': '/var/log/pid_watcher/watcher.log',
            'maxBytes': 8*1024*1024,
            'backupCount': 10,
            'level': 'DEBUG',
        },
    },
    'loggers': {
        'pid_watcher': {
            'handlers': ['std_h', 'file_h'],
            'level': 'DEBUG'
        }
    }
}

dictConfig(log_config)
logger = logging.getLogger('pid_watcher')

if __name__ == "__main__":
    while True:
        pid_infos = []
        for pid in psutil.pids():
            try:
                p = psutil.Process(pid)
                info = dict()
                info['pid'] = pid
                info['name'] = p.name()
                info['mem'] = p.memory_percent()
                info['threads'] = p.num_threads()
                info['cmdline'] = p.cmdline()
                pid_infos.append(info)
            except Exception:
                pass
        sorted_list = sorted(pid_infos, key=lambda e:e['mem'], reverse=True)
        for tmp in sorted_list:
            logger.info("%s-%s-%s-%s---%s" % (tmp['pid'], tmp['name'], tmp['mem'], tmp['threads'], tmp['cmdline']))
        time.sleep(60)

