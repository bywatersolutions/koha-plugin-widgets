# Koha Widgets Plugin

This plugin takes a slip/notice and a report id and outputs JSON with HTML embedded in it. That HTML can then be added to the DOM of a page via JavaScript to create a widget!

## Usage

The JSON can be accessed via the path `/api/v1/contrib/widgets/widget/<notice module>/<notice code>/<report id>`
This API will return a JSON object with a key `html` that contains the rendered HTML.

### Template

The results of the report are passed to the template as the variable `rows`.
Here is an example:

Report Query: `SELECT * FROM borrowers`
Notice: ```
<h1>Test Widget</h1>
<ul>
    [% FOREACH r IN rows %]
        <li>[% r.borrowernumber %]</li>
    [% END %]
</ul>
```

The notice contents are always pulled from the *print* version of the notice.
