all:
	rm -rf  *~ */*~ src/*.beam tests/*.beam tests_ebin erl_cra*;
	rm -rf _build logs log *.pod_dir;
	rm -rf _build tests_ebin ebin;
	rm -rf spec.*;
	mkdir ebin;
	erlc -I include -o ebin src/*.erl;		
	rm -rf ebin;
	git add *;
	git commit -m $(m);
	git push;
	echo Ok there you go!
build:
	rm -rf  *~ */*~ src/*.beam test/*.beam test_ebin erl_cra*;
	rm -rf _build logs log *.pod_dir;
	rm -rf deployments *_info_specs;
	rm -rf _build test_ebin ebin;
	mkdir ebin;		
	rebar3 compile;	
	cp _build/default/lib/*/ebin/* ebin;
	rm -rf _build test_ebin logs log;


clean:
	rm -rf  *~ */*~ src/*.beam test/*.beam test_ebin erl_cra*;
	rm -rf _build logs log *.pod_dir;
	rm -rf deployments *_info_specs;
	rm -rf spec.*;
	rm -rf _build test_ebin ebin

eunit:
	rm -rf  *~ */*~ src/*.beam tests/*.beam tests_ebin erl_cra*;
	rm -rf _build logs log *.pod_dir;
	rm -rf spec.*;
	rm -rf config sd;
	rm -rf rebar.lock;
	rm -rf Mnesia.*;
	rm -rf ebin;

#	tests 
	mkdir tests_ebin;
	erlc -I include -o tests_ebin tests/*.erl;
	cp tests/specs/spec.* .;
#  	dependencies
	erlc -I include -o tests_ebin ../common/src/*.erl;
	erlc -I include -o tests_ebin ../config/src/*.erl;
	erlc -I include -o tests_ebin ../nodelog/src/*.erl;
	erlc -I include -o tests_ebin ../sd/src/*.erl;
#	application
	mkdir ebin;
	erlc -I include -o ebin src/*.erl;	
	erl -pa * -pa ebin -pa tests_ebin -sname ops_test -run $(m) start -setcookie ops -hidden
