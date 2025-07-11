global with sharing class GB_weatherDataMock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"current": {"temp_c":25.4,"condition":{"text": "Sunny","icon": "//cdn.weatherapi.com/weather/64x64/day/113.png","code": 1000}}}');
        res.setStatusCode(200);
        return res;
    }
}
