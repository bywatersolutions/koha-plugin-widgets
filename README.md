# Koha Widgets Plugin

This plugin takes a slip/notice and a report id and outputs JSON with HTML embedded in it. That HTML can then be added to the DOM of a page via JavaScript to create a widget!

*NOTICE:* This plugin is alpha-level and implements no caching mechanisms.

## Usage

The JSON can be accessed via the path `/api/v1/contrib/widgets/widget/<notice module>/<notice code>/<report id>`
This API will return a JSON object with a key `html` that contains the rendered HTML.

### Template

The results of the report are passed to the template as the variable `rows`.
Here is an example:

Report Query: `SELECT * FROM borrowers`
Notice: 
```
<h1>Test Widget</h1>
<ul>
    [% FOREACH r IN rows %]
        <li>[% r.borrowernumber %]</li>
    [% END %]
</ul>
```

The notice contents are always pulled from the *print* version of the notice.

As an example, the following jQuery in _intranetuserjs_ will load the widget and place it after the *About Koha* button on the Koha home page in the staff interface:
```
$(document).ready(function() {
  $.getJSON("/api/v1/contrib/widgets/widget/catalogue/KYLE/1", function(data) {
    $(data.html).insertAfter("a.icon_koha");
  });
});
```

By default, each rendered widget is cached for 15 minutes.
If you would like to change the length of time a widget is cached, just append a GET parameter named `expiration` with your custom cache expiration time.
Expiration is defined in seconds, so a URL with a 5 minute expiration would looke like `/api/v1/contrib/widgets/widget/catalogue/KYLE/1?expiration=300`.

If your report uses parameters, you can include them in a GET parameter as well, `sql_params`.
If your report uses one paramter, you can send that parameter like `/api/v1/contrib/widgets/widget/catalogue/KYLE/1?expiration=300&sql_params=PARAM1`.
If your report uses more than one paramter, delimit them with `!@!`. For example, if your report has 3 paramters, do something like `/api/v1/contrib/widgets/widget/catalogue/KYLE/1?expiration=300&sql_params=PARAM1!@!PARAM1!@!PARAM3`.
If you need to use a literal `!@!` in your report paramter value, you are out of luck. The character set `!@!` was chosen due the unlikeliness of using it as an SQL paramter.
