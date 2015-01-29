README:

Overall Description:
This iPhone Application displays all trips between 24TH station and MLBR stations in BART at specific date. From user selections, application sends asynchronous HTTP request and get XML data. By using open source library (SMXMLDocument: https://github.com/nfarina/xmldocument), it parses xml file and returns desired information to user.

Data Acquisition from BART API:
1. This API doesn’t directly provide all the trip schedule between 24TH station and MLBR station at a date in a single xml and it only provides trips near a specific time at a date. 
2. To eliminate total numbers of http requests, the application first gets all route information in the system and select those routes which stop at departure station and then stop at arrival station. From all these routes, iterate them and send requests to find departure time and arrival time between depart and arrive stations.
3. To get detailed information of one trip, after getting its departure time, application sends requests to get a trip based on departing time.

Data Acquired:
1. RouteInfo XML: All route information
2. RouteSched XML: All trip schedule from a route
3. DepartSched XML: A trip information based on departing time

User Interface:
Users are able to select departure station, arrival station, and trip date. By clicking search button, http request is sent and a spinning icon appears indicating it is establishing network connections and data manipulation. 
If connection succeeds, users will see all trips at a specific date between departure station and arrival station on a table view.
To refresh data, simply click refresh on the top right corner.
By clicking a row of the table, application will show details of the selected trip.

Application Components:
Models:
1. RouteManager: Manipulate returned XMLData from HTTP Response. For three scenarios, routeinfo xml, routeschedule xml, depart sched xml, route manager utilizes open source library (XMLDocument) to parse XML and return desired data.
2. TripInfo: encapsulate all information of single trip.
3. ConnectionManager: responsible for sending HTTP request.

Views and Controllers:
1. ViewController: all components in first UI and responsible for collecting user inputs and parsing them to ConnectionManager to establish network connection. Display data if connection succeeds, and prompt warning otherwise.
2. ScheduleTableViewControllers: display data using table view and allow users to refresh data and view data
3. TripInfoViewController: display all information of one single trip