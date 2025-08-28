Modifying ``elearning-edx`` settings
-----------------------------------

The default settings module loaded by ``elearning-edx`` is ``tutor.production`` in production and ``tutor.development`` in development. The folders ``$(tutor config printroot)/env/apps/openedx/settings/lms`` and ``$(tutor config printroot)/env/apps/openedx/settings/cms`` are mounted as ``elearning-edx/lms/envs/tutor`` and ``elearning-edx/cms/envs/tutor`` inside the docker containers. To modify these settings you must create a plugin that implements one or more of the patch statements in those setting files. See the :ref:`plugin_development_tutorial` tutorial for more information on how to create a plugin.
