#
# Copyright (c) 2019 by Delphix. All rights reserved.
#
from __future__ import absolute_import
from datetime import date, datetime

from generated.definitions.base_model_ import (
    Model, GeneratedClassesError, GeneratedClassesTypeError)
from generated import util

class SnapshotDefinition(Model):
    """NOTE: This class is auto generated by the swagger code generator program.

    Do not edit the class manually.
    """

    def __init__(self, snapshot_name=None, cluster=None, validate=True):
        """SnapshotDefinition - a model defined in Swagger. The type of some of these
        attributes can be defined as a List[ERRORUNKNOWN]. This just means they
        are a list of any type.

            :param snapshot_name: The snapshot_name of this SnapshotDefinition.
            :type snapshot_name: str
            :param cluster: The cluster of this SnapshotDefinition.
            :type cluster: bool
            :param validate: If the validation should be done during init. This
            should only be called internally when calling from_dict.
            :type validate: bool
        """
        self.swagger_types = {
            'snapshot_name': str,
            'cluster': bool
        }

        self.attribute_map = {
            'snapshot_name': 'snapshotName',
            'cluster': 'cluster'
        }
        
        # Validating the attribute snapshot_name and then saving it.
        type_error = GeneratedClassesTypeError.type_error(SnapshotDefinition,
                                                          'snapshot_name',
                                                          snapshot_name,
                                                          str,
                                                          False)
        if validate and type_error:
            raise type_error
        self._snapshot_name = snapshot_name

        # Validating the attribute cluster and then saving it.
        type_error = GeneratedClassesTypeError.type_error(SnapshotDefinition,
                                                          'cluster',
                                                          cluster,
                                                          bool,
                                                          False)
        if validate and type_error:
            raise type_error
        self._cluster = cluster
    @classmethod
    def from_dict(cls, dikt):
        """Returns the dict as a model

        :param dikt: A dict.
        :type: dict
        :return: The snapshotDefinition of this SnapshotDefinition.
        :rtype: SnapshotDefinition
        """
        return util.deserialize_model(dikt, cls)

    @property
    def snapshot_name(self):
        """Gets the snapshot_name of this SnapshotDefinition.


        :return: The snapshot_name of this SnapshotDefinition.
        :rtype: str
        """
        return self._snapshot_name

    @snapshot_name.setter
    def snapshot_name(self, snapshot_name):
        """Sets the snapshot_name of this SnapshotDefinition.


        :param snapshot_name: The snapshot_name of this SnapshotDefinition.
        :type snapshot_name: str
        """
        # Validating the attribute snapshot_name and then saving it.
        type_error = GeneratedClassesTypeError.type_error(SnapshotDefinition,
                                                          'snapshot_name',
                                                          snapshot_name,
                                                          str,
                                                          False)
        if type_error:
            raise type_error
        self._snapshot_name = snapshot_name

    @property
    def cluster(self):
        """Gets the cluster of this SnapshotDefinition.


        :return: The cluster of this SnapshotDefinition.
        :rtype: bool
        """
        return self._cluster

    @cluster.setter
    def cluster(self, cluster):
        """Sets the cluster of this SnapshotDefinition.


        :param cluster: The cluster of this SnapshotDefinition.
        :type cluster: bool
        """
        # Validating the attribute cluster and then saving it.
        type_error = GeneratedClassesTypeError.type_error(SnapshotDefinition,
                                                          'cluster',
                                                          cluster,
                                                          bool,
                                                          False)
        if type_error:
            raise type_error
        self._cluster = cluster
