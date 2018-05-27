======
nzbget
======

Salt formula to install and configure NZBGet Usenet downloader.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

    See pillar.example, defaults.yaml for setup.

Available states
================

.. contents::
    :local:

``nzbget``
----------

Installs the nzbget package.

``nzbget.config``
-----------------

Manages the nzbget configuration file.

``nzbget.service``
------------------

Manages the user, files, and directories required to run nzbget as a system
service.
