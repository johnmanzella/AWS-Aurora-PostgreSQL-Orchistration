#
# Copyright (c) 2019 by Delphix. All rights reserved.
#
from __future__ import absolute_import
from datetime import date, datetime

from generated.definitions.base_model_ import (
    Model, GeneratedClassesError, GeneratedClassesTypeError)
from generated import util

class SourceConfigDefinition(Model):
    """NOTE: This class is auto generated by the swagger code generator program.

    Do not edit the class manually.
    """

    def __init__(self, path=None, name=None, cluster=None, validate=True):
        """SourceConfigDefinition - a model defined in Swagger. The type of some of these
        attributes can be defined as a List[ERRORUNKNOWN]. This just means they
        are a list of any type.

            :param path: The path of this SourceConfigDefinition.
            :type path: str
            :param name: The name of this SourceConfigDefinition.
            :type name: str
            :param cluster: The cluster of this SourceConfigDefinition.
            :type cluster: bool
            :param validate: If the validation should be done during init. This
            should only be called internally when calling from_dict.
            :type validate: bool
        """
        self.swagger_types = {
            'path': str,
            'name': str,
            'cluster': bool
        }

        self.attribute_map = {
            'path': 'path',
            'name': 'name',
            'cluster': 'cluster'
        }
        
        # Validating the attribute path and then saving it.
        if validate and path is None:
            raise GeneratedClassesError(
                "The required parameter 'path' must not be 'None'.")
        type_error = GeneratedClassesTypeError.type_error(SourceConfigDefinition,
                                                          'path',
                                                          path,
                                                          str,
                                                          True)
        if validate and type_error:
            raise type_error
        self._path = path

        # Validating the attribute name and then saving it.
        if validate and name is None:
            raise GeneratedClassesError(
                "The required parameter 'name' must not be 'None'.")
        type_error = GeneratedClassesTypeError.type_error(SourceConfigDefinition,
                                                          'name',
                                                          name,
                                                          str,
                                                          True)
        if validate and type_error:
            raise type_error
        self._name = name

        # Validating the attribute cluster and then saving it.
        type_error = GeneratedClassesTypeError.type_error(SourceConfigDefinition,
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
        :return: The sourceConfigDefinition of this SourceConfigDefinition.
        :rtype: SourceConfigDefinition
        """
        return util.deserialize_model(dikt, cls)

    @property
    def path(self):
        """Gets the path of this SourceConfigDefinition.

        Source Path ...

        :return: The path of this SourceConfigDefinition.
        :rtype: str
        """
        return self._path

    @path.setter
    def path(self, path):
        """Sets the path of this SourceConfigDefinition.

        Source Path ...

        :param path: The path of this SourceConfigDefinition.
        :type path: str
        """
        # Validating the attribute path and then saving it.
        if path is None:
            raise GeneratedClassesError(
                "The required parameter 'path' must not be 'None'.")
        type_error = GeneratedClassesTypeError.type_error(SourceConfigDefinition,
                                                          'path',
                                                          path,
                                                          str,
                                                          True)
        if type_error:
            raise type_error
        self._path = path

    @property
    def name(self):
        """Gets the name of this SourceConfigDefinition.

        Source Data Set Name ...

        :return: The name of this SourceConfigDefinition.
        :rtype: str
        """
        return self._name

    @name.setter
    def name(self, name):
        """Sets the name of this SourceConfigDefinition.

        Source Data Set Name ...

        :param name: The name of this SourceConfigDefinition.
        :type name: str
        """
        # Validating the attribute name and then saving it.
        if name is None:
            raise GeneratedClassesError(
                "The required parameter 'name' must not be 'None'.")
        type_error = GeneratedClassesTypeError.type_error(SourceConfigDefinition,
                                                          'name',
                                                          name,
                                                          str,
                                                          True)
        if type_error:
            raise type_error
        self._name = name

    @property
    def cluster(self):
        """Gets the cluster of this SourceConfigDefinition.

        

        :return: The cluster of this SourceConfigDefinition.
        :rtype: bool
        """
        return self._cluster

    @cluster.setter
    def cluster(self, cluster):
        """Sets the cluster of this SourceConfigDefinition.

        

        :param cluster: The cluster of this SourceConfigDefinition.
        :type cluster: bool
        """
        # Validating the attribute cluster and then saving it.
        type_error = GeneratedClassesTypeError.type_error(SourceConfigDefinition,
                                                          'cluster',
                                                          cluster,
                                                          bool,
                                                          False)
        if type_error:
            raise type_error
        self._cluster = cluster