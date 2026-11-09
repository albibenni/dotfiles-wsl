import pathlib
import subprocess
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]

class RancherInstallerTests(unittest.TestCase):
    def test_missing_distro_is_rejected_before_windows_is_called(self):
        result = subprocess.run(['bash', str(ROOT / 'scripts/install-rancher-desktop.sh'), '--distro'], capture_output=True, text=True)
        self.assertEqual(result.returncode, 2)
        self.assertIn('--distro requires', result.stderr)

    def test_invalid_distro_is_rejected_before_windows_is_called(self):
        result = subprocess.run(['bash', str(ROOT / 'scripts/install-rancher-desktop.sh'), '--distro', 'bad name'], capture_output=True, text=True)
        self.assertEqual(result.returncode, 2)
        self.assertIn('Invalid WSL distribution name', result.stderr)

if __name__ == '__main__':
    unittest.main()
