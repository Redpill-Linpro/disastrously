# User Documentation for Disastrously


**Disastrously** is the name of a incident tracker for sysops. It is written
entirely in Ruby on Rails (RoR).


## About

The purpose of the incident tracker is to report incidents. It is a one-way
communication medium between service providers and clients. In order to
understand how it works, it's useful to understand the main concepts **groups,
users** and **history**.

## Groups

A service provider create customers as groups (one group represents one
customer). The group has a notification mail address which will receive
incident reports, and a reply-to mail address which will be set on outgoing
mails to that customer.

A customer/group can be a member of other groups. If one group receives an
incident, then all groups that is a member of that group will receive the same
incident report as well. This goes on recursively (while making sure it never
sends out more than one incident report to each group, even though infinite
loops are created).

A group does not need to have a notification mail. This allows for actual
grouping, e.g having a group named "network" without notification mail that has
a number of other groups as its members. Whenever an incident is created for
the group "network" the groups that are a member of the network group would
receive the incident.

If an incident report is changed/updated, a new incident report is sent out
with the added text that it is an update to a previous report.

## Users

Users are only used to access the system. A user belongs to a user type which
will decide its access rights. A client would typically only be allowed to read
incidents. An operator would typically be allowed to both read incidents and
create incidents for the groups that it is a member of. And finally a user with
admin rights can read and create any incident and also create groups and users
and decide access rights.

## History

Whenever an incident is created, it is linked to a specific group. Every user
that is a member of that group will get that incident added to their history
list. The history list is personal and each user has their own. If a user is
moved between different groups (added to new groups and removed from some old
one) they will gain access to read all the incidents for the new groups they
are a member of and lose access to read the incidents in the groups they no
longer are a member of. However, the incidents that were created in a group
while they where a member of it still remains in their history to read, even
though they have lost access to that group.

If a group is deleted by an admin, all associated incidents are destroyed as
well (even those in users personal history).

## Incidents

The core of the incident tracker is naturally the incident model. A single
incident object normally represents a single incident or service window event.

(Because an incident can be a service window, which is pre-announced
maintanence work, the word "incident" is actually misleading, and the word
"event" would probably be a better fit.)

An incident has:

* Title and description.

* A severity choosen from a list of predefined (and customizable) values.

* *handled_by* chosen from a list of all registered users which is the person
  who is primarly responsible for handling the situation.

* Associations to a group or groups that this incident affects.

  It is possible to select several groups that are affected by a single
  incident. Whenever a group is assoicated with an incident, all groups that
  are members of that group will (implicitly) be associated also.

* Automatically created notifications for all groups or optionally only new groups if
  updating an existing incident.

  This option is reset every time an incident is saved, which means it has to
  be activated explicitly every time it is used. This is done in order to
  prevent creating notifications for customers (and thus mass mailing them) in
  vain.

* Timestamps which represent significant events.

  Each timestamp has a datetime, an SLA marker, a service window marker and a
  comment field. A timestamp can be marked with SLA meaning that from now on
  this incident affects SLA for the associated groups. The next timestamp
  without the SLA marker stops the SLA period. The same goes for the service
  window marker. An optional comment can be added to explain what happened.
  Also, a timestamp need not be related to SLA or service window, which can be
  convenient to log events before or after the most significant period.

* A marker for "Unknown start" and "Still ongoing".

  Despite the flexibility that the timestamps give, sometimes it is useful to
  also record that it is currently unknown when this incident started.
  Sometimes it is also practial to be able to send out a notification to
  affected customers before the incident is resolved, in which case "still
  ongoing" would be used.

* Overrides (a.k.a. children incidents).

  Sometimes a single incident affects several groups, but in sligthly different
  ways. This can be effectively handled by creating an incident which affects
  several groups and then add one or more "overrides" for one or more groups
  and one or more fields/columns. When the notification for any of the groups
  associated with an override is sent out, the notification will include the
  data from the override and user the "master" incident to fill in the blanks.

  Overriding columns is supported for all fields except timestamps. The reason
  timestamps isn't supported is because it requires Active Scaffold to generate
  a "subform in a subform", which it currently doesn't support.

  Note that each override has its own notification settings. If a group is
  associated with only the master incident or only the child incident (the
  override), then the setting from the incident it is associated with is used
  when deciding if a notification should be generated. If it is associated with
  both, then the setting from the child incident (the override) takes
  precedent.

  This allows overrides to be used only for notifications, by creating an
  override with no affected columns (see below) and by specifying desired
  notification method, some groups associated with an incident can receive a
  different type of notification than others for the same incident.

* Affected columns.

  The affected columns decides which columns are in use for this incident.
  Naturally it is mostly relevant for overrides.

