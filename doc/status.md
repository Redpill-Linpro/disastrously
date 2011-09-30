# Status

Known work needed on Disastrously as of July 2011:

* Disastrously still uses Rails 2.3. An upgrade to Rails 3 would be beneficial.

* Disastrously uses Active Scaffold as the foundation for the entire
  application. Unfortunately, Active Scaffold development has stalled, so
  upgrading to another framework (or custom code) should be initiated. The
  functionality used by Disastrously is pushing the boundry for what Active
  Scaffold can provide.

  The problem is that changing the framework would require a port of all the code
  to the new framework, which would probably require substantial amounts of
  work. Since Disastrously is not a big project, it is probably doable.

* The tests could definitely be better.
