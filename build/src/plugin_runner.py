#
# Copyright (c) 2020 by Delphix. All rights reserved.
#

import pkgutil
import logging
import random

from datetime import datetime

from dlpx.virtualization.platform import Mount, MountSpecification, Plugin

from dlpx.virtualization import libs
from dlpx.virtualization.platform.exceptions import UserError

from generated.definitions import (
    RepositoryDefinition,
    SourceConfigDefinition,
    SnapshotDefinition,
)

from dlpx.virtualization.libs import PlatformHandler

from utils import library

plugin_name = "aws_sdk"

# Setup the logger.
library._setup_logger()

# logging.getLogger(__name__) is the convention way to get a logger in Python.
# It returns a new logger per module and will be a child of the root logger.
# Since we setup the root logger, nothing else needs to be done to set this
# one up.
logger = logging.getLogger(__name__)

plugin = Plugin()

#
# Below is an example of the repository discovery operation.
#
# NOTE: The decorators are defined on the 'plugin' object created above.
#
# Mark the function below as the operation that does repository discovery.
@plugin.discovery.repository()
def repository_discovery(source_connection):
    #
    # This is an object generated from the repositoryDefinition schema.
    # In order to use it locally you must run the 'build -g' command provided
    # by the SDK tools from the plugin's root directory.
    #

    return [RepositoryDefinition(name='AWS Plugin')]


@plugin.discovery.source_config()
def source_config_discovery(source_connection, repository):
    #
    # To have automatic discovery of source configs, return a list of
    # SourceConfigDefinitions similar to the list of
    # RepositoryDefinitions above.
    #

    return []


@plugin.linked.start_staging()
def start_staging(repository, source_config, staged_source):
    library._record_hook("staging start", staged_source.staged_connection)
    library._set_running(staged_source.staged_connection, staged_source.guid)


@plugin.linked.stop_staging()
def stop_staging(repository, source_config, staged_source):
    library._record_hook("staging stop", staged_source.staged_connection)
    library._set_stopped(staged_source.staged_connection, staged_source.guid)


@plugin.linked.pre_snapshot()
def copy_data_from_source(staged_source, repository, source_config, optional_snapshot_parameters):
    library._record_hook("staging pre snapshot", staged_source.staged_connection)
    stage_mount_path = staged_source.mount.mount_path
    #data_location = "{}@{}:{}".format(staged_source.parameters.username,
    #    staged_source.parameters.source_address,
    #    source_config.path)

    #if optional_snapshot_parameters.resync:
     #   logger.debug("{\"resync\": 1000}") 
    #else:
        #logger.debug("{\"sync\": 10}")

    #logger.debug("snapshot_parameters: "+str(snapshot_parameters))

    logger.debug("staged_source.parameters.source_host")
    logger.debug("staged_source.parameters.source_port")

    #library._record_hook("staging", staged_source.parameters.source_host)

    #
    # Sample utils/library.py method ...
    #
    # logger.debug(str(library.get_platform(staged_source.staged_connection)))


@plugin.linked.post_snapshot()
def linked_post_snapshot(staged_source,
                         repository,
                         source_config,
                         optional_snapshot_parameters):
    library._record_hook("staging post snapshot", staged_source.staged_connection)

    logger.debug("Name: "+str(source_config.name))
    #logger.debug(str(library.get_platform(staged_source.staged_connection)))
    #logger.debug(str(staged_source.parameters))

    snapshot = SnapshotDefinition()
    #if snapshot_parameters.resync:
    #else:

    stage_mount_path = staged_source.mount.mount_path

    dt=datetime.now()
    x=dt.strftime("%Y-%m-%d-%H-%M-%S")
    snapshot.snapshot_name = "delphix-"+str(source_config.name)+"-"+x   
    snapshot.cluster = source_config.cluster

    vars = {"SNAP_DB": source_config.name, "MOUNT_PATH": stage_mount_path, "SNAP_NAME": snapshot.snapshot_name, "CLUSTER": str(snapshot.cluster)}
    script = pkgutil.get_data("resources", "snap.sh")
    result = libs.run_bash(staged_source.staged_connection, script, variables=vars)     # , check=true

    logger.debug(result.exit_code)
    logger.debug(result.stdout)
    logger.debug(result.stderr)

    if result.exit_code != 0:
        raise UserError(
            "Could not create Snapshot ...",
            "Ensure that ... for {}.".format(staged_source.parameters.source_host),
            result.stderr)

    return snapshot			# SnapshotDefinition()


@plugin.linked.mount_specification()
def linked_mount_specification(staged_source, repository):
    mount_location = staged_source.parameters.mount_location
    mount = Mount(staged_source.staged_connection.environment, mount_location)

    return MountSpecification([mount])


#
# worker currently runs every 10 seconds, need to wait for fix ...
# until then, move worker code to postSnapshot ...
#
#@plugin.linked.worker()
#def worker(staged_source, repository, source_config):
#    #vars = {"staged_source": str(staged_source), "repository": str(repository), "source_config": str(source_config)}
#    stage_mount_path = staged_source.mount.mount_path
#    ##library_content = pkgutil.get_data("resources", "library.sh")
#    library_content = "test"
##        "DLPX_BIN_DIRECTORY": staged_source.connection.environment.host.binary_path 
#    #    "PG_STAGED_PORT": str(staged_source.parameters.sourcePort),
#
#    vars = {
#        "DLPX_LIBRARY_SOURCE": library_content,
#        "DLPX_DATA_DIRECTORY": stage_mount_path,
#        "DLPX_PLUGIN_WORKFLOW": "worker",
#        "ss_conn_user": str(staged_source.staged_connection.user.name),
#        "ss_conn_env": str(staged_source.staged_connection.environment.host.name), 
#        "ss_params": str(staged_source.parameters), 
#        "ss_mount_path": str(staged_source.mount.mount_path), 
#        "ss_guid": str(staged_source.guid), 
#        "repository": str(repository), 
#        "source_config": str(source_config)
#    }
#    script = pkgutil.get_data("resources", "worker.sh")
#    result = libs.run_bash(staged_source.staged_connection, script, variables=vars)     # , check=true
#
#    logger.debug(result.exit_code)
#    logger.debug(result.stdout)
#    logger.debug(result.stderr)
#    pass


@plugin.virtual.configure()
def configure_new_vdb(virtual_source, snapshot, repository):
    mount_location = virtual_source.parameters.mount_location
    #name = "VDB mounted at {}".format(mount_location)
    name = virtual_source.parameters.name
    snap_name=snapshot.snapshot_name
    cluster=snapshot.cluster
    db_instance=virtual_source.parameters.db_instance
    subnet_group=virtual_source.parameters.subnet_group

    #vars = {"VDB_NAME": name, "MOUNT_PATH": mount_location, "SNAPSHOT": snapshot, "REPOSITORY": repository, "VIRTUAL_SOURCE": virtual_source}
    vars = {"VDB_NAME": name, "MOUNT_PATH": mount_location, "SNAP": snap_name, "CLUSTER": str(cluster), "DB_INSTANCE": db_instance, "SUBNET_GROUP": subnet_group}
    script = pkgutil.get_data("resources", "provision.sh")
    result = libs.run_bash(virtual_source.connection, script, variables=vars)     # , check=true

    logger.debug(result.exit_code)
    logger.debug(result.stdout)
    logger.debug(result.stderr)

    if result.exit_code != 0:
        raise UserError(
            "Could not provision AWS DB ...",
            "Ensure that connection works for {}.".format(virtual_source.connection.environment.host),
            result.stderr)

    return SourceConfigDefinition(path=mount_location, name=name, cluster=cluster)


@plugin.virtual.reconfigure()
def reconfigure_existing_vdb(virtual_source, repository, source_config, snapshot):
    return source_config


@plugin.virtual.post_snapshot()
def virtual_post_snapshot(virtual_source, repository, source_config):
    ###snapshot.snapshot_name = virtual_source.parameters.snapshot_name
    snapshot = SnapshotDefinition()
    #if snapshot_parameters.resync:
    #else:

    virtual_mount_path = virtual_source.parameters.mount_location

    dt=datetime.now()
    x=dt.strftime("%Y-%m-%d-%H-%M-%S")
    snapshot.snapshot_name = "delphix-"+str(virtual_source.parameters.name)+"-"+x
    snapshot.cluster = source_config.cluster

    vars = {"SNAP_DB": virtual_source.parameters.name, "MOUNT_PATH": virtual_mount_path, "SNAP_NAME": snapshot.snapshot_name, "CLUSTER": str(snapshot.cluster)}
    script = pkgutil.get_data("resources", "snap.sh")
    result = libs.run_bash(virtual_source.connection, script, variables=vars)     # , check=true

    logger.debug(result.exit_code)
    logger.debug(result.stdout)
    logger.debug(result.stderr)

    if result.exit_code != 0:
        raise UserError(
            "Could not create snapshot ...",
            "Ensure that ... ",
            result.stderr)

    return snapshot  


@plugin.virtual.mount_specification()
def virtual_mount_specification(virtual_source, repository):
    mount_location = virtual_source.parameters.mount_location
    mount = Mount(virtual_source.connection.environment, mount_location)

    return MountSpecification([mount])

