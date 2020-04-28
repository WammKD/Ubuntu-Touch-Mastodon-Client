var SchemeFunctions =
	function() {
		biwaScheme.define_libfunc("uri-encode", 1, 1, function(args) {
		                                              	biwaScheme.assert_string(args[0]);

		                                              	return encodeURI(args[0]);
		                                              });

		biwaScheme.define_libfunc("string->uri", 1, 1, function(args) {
		                                               	biwaScheme.assert_string(args[0]);

		                                               	return Qt.resolvedUrl(args[0]);
		                                               });

		biwaScheme.define_libfunc("string-contains",
		                          2,
		                          2,
		                          function(args) {
		                          	biwaScheme.assert_string(args[0]);
		                          	biwaScheme.assert_string(args[1]);

		                          	if(args[0].includes(args[1])) {
		                          		return args[0].indexOf(args[1]);
		                          	} else {
		                          		return false;
																}
															});

		biwaScheme.define_libfunc("string-contains-ci",
		                          2,
		                          2,
		                          function(args) {
		                          	biwaScheme.assert_string(args[0]);
		                          	biwaScheme.assert_string(args[1]);

		                          	var a0 = args[0].toLowerCase(),
		                          	    a1 = args[1].toLowerCase();

		                          	if(a0.includes(a1)) {
		                          		return a0.indexOf(a1);
		                          	} else {
		                          		return false;
																}
															});

		biwaScheme.define_libfunc("string-split",
															2,
															2,
															function(args) {
		                          	biwaScheme.assert_string(args[0]);
		                          	biwaScheme.assert_char(args[1]);

		                          	return biwaScheme.array_to_list(args[0].split(args[1].value));
		                          });

		biwaScheme.define_libfunc("string-trim",
															1,
															1,
															function(args) {
		                          	biwaScheme.assert_string(args[0]);

		                          	return args[0].trim();
		                          });

		biwaScheme.define_libfunc("string-null?",
															1,
															1,
															function(args) {
		                          	biwaScheme.assert_string(args[0]);

		                          	return args[0] === "";
		                          });

		biwaScheme.define_libfunc("http-get",
		                          2,
		                          3,
		                          function(args, intp) {
		                          	biwaScheme.assert_string(args[0]);
		                          	biwaScheme.assert_list(args[1]);

		                          	var xhr     = new XMLHttpRequest(),
		                          	    headers = biwaScheme.CoreEnv["list->vector"]([args[1]]);

		                          	xhr.open("GET", args[0], !!args[2]);

		                          	for(var headerIndex in headers) {
		                          		xhr.setRequestHeader(headers[headerIndex].car,
		                          		                     headers[headerIndex].cdr);
		                          	}

		                          	if(args[2]) {
		                          		xhr.onreadystatechange = function() {
		                          		                         	if(xhr.status     == 200                 &&
		                          		                         	   xhr.readyState == XMLHttpRequest.DONE) {
		                          		                         		intp.invoke_closure(args[2],
		                          		                         		                    [xhr]);
		                          		                         	}
		                          		                         };
		                          		xhr.send();
		                          	} else {
		                          		xhr.send();

		                          		if(xhr.status === 200) {
		                          			return xhr;
		                          		} else {
		                          			console.log("GET call FAILED!");
		                          			return false;
		                          		}
		                          	}
		                          });
		biwaScheme.define_libfunc("http-post",
		                          2,
		                          3,
		                          function(args, intp) {
		                          	biwaScheme.assert_string(args[0]);
		                          	biwaScheme.assert_list(args[1]);

		                          	var xhr     = new XMLHttpRequest(),
		                          	    headers = biwaScheme.CoreEnv["list->vector"]([args[1]]);

		                          	xhr.open("POST", args[0], !!args[2]);

		                          	for(var headerIndex in headers) {
		                          		xhr.setRequestHeader(headers[headerIndex].car,
		                          		                     headers[headerIndex].cdr);
		                          	}

		                          	if(args[2]) {
		                          		xhr.onreadystatechange = function() {
		                          		                         	if(xhr.status     == 200                 &&
		                          		                         	   xhr.readyState == XMLHttpRequest.DONE) {
		                          		                         		intp.invoke_closure(args[2],
		                          		                         		                    [xhr]);
		                          		                         	}
		                          		                         };
		                          		xhr.send();
		                          	} else {
		                          		xhr.send();

		                          		if(xhr.status === 200) {
		                          			return xhr;
		                          		} else {
		                          			console.log("POST call FAILED!");
		                          			return false;
		                          		}
		                          	}
		                          });
		biwaScheme.define_libfunc("xhr-response-text",
		                          1,
		                          1,
		                          function(args) {
		                          	return args[0].responseText;
		                          });
		biwaScheme.define_libfunc("xhr-response-header",
		                          2,
		                          2,
		                          function(args) {
		                          	return args[0].getResponseHeader(args[1]);
		                          });

		biwaScheme.define_libfunc("string->json", 1, 1, function(args) {
		                                                	biwaScheme.assert_string(args[0]);

		                                                	return JSON.parse(args[0]);
		                                                });
	};
