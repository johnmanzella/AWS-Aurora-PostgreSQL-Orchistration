import pkgutil
import logging

import posixpath
import random

from datetime import datetime

from dlpx.virtualization import libs
from dlpx.virtualization.platform.exceptions import UserError

logger = logging.getLogger(__name__)

# This should probably be defined in its own module outside
# of the plugin's entry point file. It is here for simplicity.
def _setup_logger():
    # This will log the time, level, filename, line number, and log message.
    log_message_format = '[%(asctime)s] [%(levelname)s] [%(filename)s:%(lineno)d] %(message)s'
    log_message_date_format = '%Y-%m-%d %H:%M:%S'

    # Create a custom formatter. This will help with diagnosability.
    formatter = logging.Formatter(log_message_format, datefmt= log_message_date_format)

    platform_handler = libs.PlatformHandler()
    platform_handler.setFormatter(formatter)

    logger = logging.getLogger()
    logger.addHandler(platform_handler)

    # By default the root logger's level is logging.WARNING.
    logger.setLevel(logging.DEBUG)


def execute_sql(source_connection, install_name, script_name):
    psql_script = pkgutil.get_data("resources", "execute_sql.sh")
    sql_script = pkgutil.get_data("resources", script_name)

    result = libs.run_bash(
        source_connection, psql_script, variables={"SCRIPT": sql_script}, check=True
    )
    return result.stdout


def execute_shell(source_connection, script_name):
    script = pkgutil.get_data("resources", script_name)

    result = libs.run_bash(source_connection, script, check=True)
    return result.stdout


def get_platform(connection):
    vars = {}
    result = libs.run_bash(connection, "uname -a", vars)
    return result.stdout


def _record_hook(hook_name, connection):
    logger.info('Running %s', hook_name)
    libs.run_bash(connection, "echo '{}:{}' >> {}".format(
        datetime.now(), "Running {}".format(hook_name),
        posixpath.join("/var/tmp", "pythonStaging.log")))


def _set_running(connection, guid):
    libs.run_bash(connection, "echo {} >> /var/tmp/running-{}".format(
        random.random(), guid))


def _set_stopped(connection, guid):
    libs.run_bash(connection, "rm -f /var/tmp/running-{}".format(guid))


