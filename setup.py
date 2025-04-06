from setuptools import setup, find_packages

setup(
    name='ta-nix-verifier',
    version='1.0.0',
    author='Levi Lima Greter',
    description='CLI para verificação de comandos e paths do Splunk TA-nix',
    packages=find_packages(),
    entry_points={
        'console_scripts': [
            'ta-nix-verifier=ta_nix_verifier.cli:main',
        ],
    },
    classifiers=[
        'Programming Language :: Python :: 3',
        'License :: OSI Approved :: MIT License',
        'Operating System :: POSIX :: Linux',
    ],
    python_requires='>=3.6',
)
