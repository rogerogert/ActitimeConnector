// This file contains your Data Connector logic
section ActitimeConnector;

BaseUrl = "https://online.actitime.com/hexagon1/api/v1/";

[DataSource.Kind="ActitimeConnector", Publish="ActitimeConnector.Publish"]
shared ActitimeConnector.Contents = () =>
    let
		result = TransformData()
    in
		result;

GetTimetrack = () =>
	let
		source = Json.Document(Web.Contents(BaseUrl & "timetrack?dateFrom=2019-04-01&includeReferenced=comments,users")),
		value = source[data],
		toTable = Table.FromList(value, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
		exp = Table.ExpandRecordColumn(toTable, "Column1", {"userId", "records", "dayOffset"}),
		exp2 = Table.ExpandListColumn(exp, "records"),
		exp3 = Table.ExpandRecordColumn(exp2, "records", {"taskId", "time", "comment"})
	in
		exp3;

GetUsers = () =>
	let
		source = Json.Document(Web.Contents(BaseUrl & "users?offset=0&limit=1000")),
		value = source[items],
		toTable = Table.FromList(value, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
		exp = Table.ExpandRecordColumn(toTable, "Column1", {"id", "email", "fullName"})
	in
		exp;

GetTasks = () =>
	let
		source = Json.Document(Web.Contents(BaseUrl & "tasks?offset=0&limit=1000")),
		value = source[items],
		toTable = Table.FromList(value, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
		exp = Table.ExpandRecordColumn(toTable, "Column1", {"id", "name", "description", "status", "customerId", "projectId"})
	in
		exp;

TimeTrackUsersNav = () as table =>
	let
		source = #table({"Table", "Data"}, {
			{"Users", GetUsers()},
			{"Timetrack", GetTimetrack()},
			{"Tasks", GetTasks()}
		})
	in
		source;

TransformData = () =>
	let
	source = TimeTrackUsersNav(),
	TT = source[Data]{1},
	U = source[Data]{0},
	T = source[Data]{2},
    JoinTables = Table.NestedJoin(TT,{"userId"},U,{"id"},"Users",JoinKind.LeftOuter),
    ExpandUsers = Table.ExpandTableColumn(JoinTables, "Users", {"email", "fullName"}, {"Email", "Name"}),
	JoinTasks = Table.NestedJoin(ExpandUsers, {"taskId"}, T, {"id"}, "Tasks", JoinKind.LeftOuter),
	ExpandTasks = Table.ExpandTableColumn(JoinTasks, "Tasks", {"name", "status"}, {"Task", "Status"})

in
    ExpandTasks;


// Data Source Kind description
ActitimeConnector = [
    Authentication = [
		UsernamePassword = []
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
