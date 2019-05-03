// This file contains your Data Connector logic
section ActitimeConnector;

[DataSource.Kind="ActitimeConnector", Publish="ActitimeConnector.Publish"]
shared ActitimeConnector.Contents = (optional message as text) =>
    let
        _message = if (message <> null) then message else "(no message)",
        a = "Hello from ActitimeConnector: " & _message
    in
        a;

// Data Source Kind description
ActitimeConnector = [
    Authentication = [
        // Key = [],
        // UsernamePassword = [],
        // Windows = [],
        Implicit = []
    ],
    Label = Extension.LoadString("DataSourceLabel")
];

// Data Source UI publishing description
ActitimeConnector.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp") },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = ActitimeConnector.Icons,
    SourceTypeImage = ActitimeConnector.Icons
];

ActitimeConnector.Icons = [
    Icon16 = { Extension.Contents("ActitimeConnector16.png"), Extension.Contents("ActitimeConnector20.png"), Extension.Contents("ActitimeConnector24.png"), Extension.Contents("ActitimeConnector32.png") },
    Icon32 = { Extension.Contents("ActitimeConnector32.png"), Extension.Contents("ActitimeConnector40.png"), Extension.Contents("ActitimeConnector48.png"), Extension.Contents("ActitimeConnector64.png") }
];
