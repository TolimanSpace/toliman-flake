from jax.lib import xla_bridge


def main():
    print(xla_bridge.get_backend().platform)
