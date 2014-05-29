Metriclient
===========

Flexible event and error reporting server

## About metriclient

Metriclient is a specification for storing structured data to represent events
and errors coming from your application. It comes bundled with a server to store
them, and a set of scripts to help you extract information from it.

It is designed to be an independent server that specializes on error
recollection. It plays well with [Lithium](https://github.com/azendal/lithium)
and [Cobalt](https://github.com/benbeltran/cobalt), since they are designed for
execution tracing and message formatting themselves, but they are not required.

## Events and errors

Events are the central component in metriclient. They are data records that
contain the information you want to track.

The structure of an event is:

    id
    event_type
    created_at
    updated_at

Errors are no different than events, but are more specialized events that come
with more information about the errors on your application. They are recorded in
a different table, and have more fields that reflect the nature of an error or
can aid in detecting and debugging, such as `line`, `url` and `user_agent`

The fields for an error are:

    id
    url
    frame
    user_agent
    scoped_class_name
    meta
    created_at
    updated_at

### Field description

* `id`, `created_at`, `updated_at`: Standard sql id and timestamps
* `event_type`: Send the name of the event you are interested in (e.g.:
                'login_button:click').
* `error`: String that holds the error message, passed from the client.
* `url`: Intended for error catching in the frontend, this holds the url where
         the error comes from.
* `user_agent`: Also for frontend error catching, pass the user agent from where
                the request originated.
* `scoped_class_name`: When using Lithium error catching, this indicates the
                       Neon class where it originated.
* `frame`: Defines the scope or module in which the error generated, not
           necessarily HTML frame but application frame.
* `meta`: This can hold arbitrary data you want to send from your application.
          The errors table saves the meta info as text, so it works best for
          unstructured data (suck as error stack traces). For structured data,
          you may want to look at the [Meta table](#meta-table)

## <a name="meta-table"></a> Meta table

Aside from the standard event fields, you can store any arbitrary structured
data in the `events_meta` table. The metriclient API does the extraction
automatically if you pass an object to the `meta` attribute

The `event_meta` table holds the following fields:

* `id`: Standard sql id
* `key`: The name of the key in the metadata
* `value`: The value associated with the key coming from the metadata
* `event_id`: Foreign key referencing the event from which this meta info comes
              from

## API

The metriclient API consists of the following methods

### `POST /api/v1/events`

#### Parameters:

`event`: A JSON object containing all the required fields for the event. It can
         also contain the special field `data`, to store metaadata related to
         the event.

### `POST /api/v1/errors`

`event`: A JSON object containing all the required fields for the error.

and the web view for errors

### `GET /errors/:id`

Shows the json object of the record with that id

#### Parameters:

`id`: The id of the error record

## Archiving

The metriclient server comes bundled with scripts for archiving, since it is
expected that you'd want to store a large number of events and errors.

You can use the rake tasks for manually making archive backups of your database,
or integrate them with your deploy and provisioning system for scheduling them.

The data is archived in tables named `events_archive`, `events_meta_archive` and
`errors_archive` with the same schema as the original tables.

It is recommended that you use an ARCHIVE storage engine for the database since
the archive is intended for read-only, there are no updates and inserts are on
demand

## Examples


    $ ./script/db/archive config/myproject.yml
    $ ./script/db/clean   config/myproject.yml


    # Example of myproject.yml:
    # -------------------------------------------------------------------------
    # host      : localhost
    # database  : metriclient_dev
    # username  : root
    # password  :
    # tables    :
    #   archive:  [events, errors, event_meta]
    #   clean:  [events, errors]
    # -------------------------------------------------------------------------


You should add something similar to your provisioning engine.
Probably in a cron or something, it is up to you to setup the right env though.

Note: We recommend archiving every hour, and cleaning once a day.

Note: MySQL dumps fall outside of this app's realm, you should provision that yourself!

### Simple event tracking

Send event info to the API, from a node.js client

    var request = require("request");

    request({
        uri : 'http://my.metriclient.server.com/events',
        method: 'POST',
        form: {
            event: {
                event_type: 'user:login',
                data: {
                    userId: 10,
                    siteVersion: '1.0'
                }
            }
        }
    }, function(error, response, body) {
        console.log(body);
    });

### Frontend Error tracking

In this example you can set up error catching and send detailed info to the
server. The example is using Lithium, but you can use it with try/catch or
standard onError events.

    Li.Engine.error.push(function (data) {
        var className = data.spy.targetObject.className || data.scope.constructor.className;
        var methoName = data.spy.methodName;
        $.post('http://my.metriclient.server.com/errors', {
            data : {
                event : {
                    userAgent : navigator.userAgent,
                    scopedClassName : className,
                    error : data.error.message,
                    meta : data.error.stack
                }
            },
            success : { ... }
        });
    });

## Installation

For installing, first you need to create your `config/database.yml` file, with
your database settings. The keys should be the name of your subdomains if want
to have multiple projects reporting to different subdomains in the same server.
For using just one database without subdomains, you can use the `default` key.

```yaml
default:
  development:
    adapter: mysql2
    database: database_name
    username: user
    password: 123abc
    host: localhost
  production:
    adapter: mysql2
    database: metriclient
    username: root
    password: 123abc
    host: localhost

other_subdomain:
  development:
    ...
  production:
    ...
```

Then you need to create the database and run the migrations

```bash
$ RACK_ENV=production rake db:create
$ RACK_ENV=production rake db:migrate
```

This will set up the database. Only thing left you need is to run the server,
using whatever web server you decide

```bash
$ RACK_ENV=production unicorn_rails -c config/unicorn.rb
```
