.PHONY: test install clean

test:
	pytest -xv

install:
	python3 -m pip install -r requirements.txt

clean:
	for name in .pytest_cache __pycache__ .vsidea .idea .mypy_cache; do find . -name $$name -exec rm -rf {} \; 2>/dev/null; done
