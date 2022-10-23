from myapp.something import message


def test_message__returns_hello_world():
    assert message() == "Hello world!"
