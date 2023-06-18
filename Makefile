all: clear generate_ignition serve

generate_ignition:
	butane --pretty --strict k8s-node.yaml > k8s-node.ign

clear:
	rm *.ign

serve:
	python3 -m http.server
