// Import the JsonSlurper class to parse Dockerhub API response
import groovy.json.JsonSlurper
// Set the URL we want to read from, it is MySQL from official Library for this example, limited to 20 results only.
// set name repository is bookstore-fe to get image frontend
docker_image_tags_url = "https://registry.thienvuvan.io.vn/api/v2.0/projects/emarket/repositories/emark-be-prd/artifacts?page=1&page_size=100&with_tag=true&with_label=false&with_scan_overview=false&with_signature=false&with_immutable_status=false&with_accessory=false"
try {
    // Set requirements for the HTTP GET request, you can add Content-Type headers and so on...
    def http_client = new URL(docker_image_tags_url).openConnection() as HttpURLConnection
    http_client.setRequestMethod('GET')
    // String userCredentials = "admin:Harbor12345";
    // String basicAuth = "Basic " + new String(Base64.getEncoder().encode(userCredentials.getBytes()));
    http_client.setRequestProperty ("Accept", "*/*");
    http_client.setRequestProperty ("Authorization", "Basic YWRtaW46SGFyYm9yMTIzNDU=");
    http_client.setRequestProperty ("X-Accept-Vulnerabilities", "application/vnd.security.vulnerability.report; version=1.1, application/vnd.scanner.adapter.vuln.report.harbor+json; version=1.0");
    
    // Run the HTTP request
    http_client.connect()
    // Prepare a variable where we save parsed JSON as a HashMap, it's good for our use case, as we just need the 'name' of each tag.
    def dockerhub_response = [:]
    // Check if we got HTTP 200, otherwise exit
    if (http_client.responseCode == 200) {
        dockerhub_response = new JsonSlurper().parseText(http_client.inputStream.getText('UTF-8'))
    } else {
        println("HTTP response error")
        System.exit(0)
    }
    // Prepare a List to collect the tag names into
    def image_tag_list = []
    // Iterate the HashMap of all Tags and grab only their "names" into our List
     dockerhub_response.each { tag_metadata ->
        tag_metadata.tags.each { tag ->
            image_tag_list.add(tag.name)
        }
    }
    // The returned value MUST be a Groovy type of List or a related type (inherited from List)
    // It is necessary for the Active Choice plugin to display results in a combo-box
    if (action == "rollback" && project == "backend") return image_tag_list.sort()
    else return ["none"]
} catch (Exception e) {
         // handle exceptions like timeout, connection errors, etc.
         println(e)
}