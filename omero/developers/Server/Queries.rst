Using server queries internally
===============================

.. topic:: Overview

    This page is aimed at internal server developers and does not
    contain information for how to perform API queries. If that is the kind of
    information you are looking for, you may find
    :doc:`/developers/Modules/Api` more useful as a starting point.
    OME's :presentations:`Hibernate 3.5 Training
    <2017/Team-Training/Hibernate/>` additionally provides information
    on both API queries and server internals.

.. figure:: /images/omero-queries-queryfactory-collaboration.png
  :align: center
  :alt: omero.services.query

  omero.services.query

Introduction
------------

The ome.services.queries package is intended to allow for the easy
definition of queries by both developers and clients. Due to the
fragility of HQL defined queries, a framework allowing for easy
definition, multiple formats (Velocity templates, Database values, class
files), and transparent lookup is critical.

Lookup happens among all ``QuerySources`` that are registered with the
``QueryFactory`` instance present in OMERO services. The first non-null
Query instance returned by a ``QuerySource`` for a given String id is
used.

Queries implement the ``HibernateCallback`` interface and are passed
directly into an ``HibernateTemplate`` instance. Therefore, care should
be taken as to which ``QuerySources`` are registered with the
``QueryFactory``.

Parameters
----------

Critical for using queries is the specification of named parameters,
number of results to return, offset of the first result to return etc.
These features are offered by the ome.parameters package. The
ome.parameters.Parameters class is the starting point for building new
parameters (although the ome.parameters.Filter object is used by some
methods).

To specify parameters, instantiate a Parameters object either with or
without a Filter object argument. The version with Filter object is
useful for specifying the number of results to be returned and whether
or not a java.util.Collection or a ome.model.IObject instance will be
returned. For example,

::

            Parameters p = new Parameters( new Filter().unique() );

will specify that the given query should return a single instance. An
exception will be thrown if more than one result is found.

::

            Parameters p = new Parameters( new Filter().unique().page(0,1) );

However, this will guarantee that only one result will be returned, since
more than 1 result ("maxResults") will be ignored. Here, an ordering of
the results might make sense.

Once a Parameters instance is available, named parameters can be added
using any of the ``add…()`` methods. These parameters will be
dynamically bound during query preparation. For example, a query of the
form:

::

            select e from Experimenter e where omeName = :name

has one named parameter "name", which can be specified by the call:

::

            parameters.addString("name","<myNameHere>");

Positional parameters of the form

::

            select e from Experimenter where omeName = ?

are not supported.

Adding queries
--------------

Subclassing query
~~~~~~~~~~~~~~~~~

Other than by defining String queries via ``new QueryDef()`` TBD, the
easiest way to create queries is to subclass ome.services.query.Query.
The only non-optional requirements on the Query implementor are then to
define the (possibly optional) named parameters to the Query, and to
override the "buildQuery" (which must call one and only one of
"setQuery()" or "setCriteria()")

Other than that, the Query implementor can enable filters on the
Hibernate session (an attempt is made to clean up after the Query runs),
and in general use any of the Hibernate session methods.

Defining a QuerySource
----------------------

A more involved but perhaps more rewarding method would be to implement
``QuerySource`` and configure ``QueryFactory`` to lookup query ids also
in your ``QuerySource``. This would allow you to write Velocity (or
Freemarker/Ruby/Python/Groovy…) ``QuerySources`` which use some form
of templating or scripting to generate HQL queries.
