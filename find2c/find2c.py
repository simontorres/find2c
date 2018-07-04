import argparse
import logging

log_format = '[%(asctime)s][%(levelname)8s]: %(message)s'
date_format = '%I:%M:%S%p'

# formatter = logging.Formatter(fmt=log_format,
#                               datefmt=date_format)

logging.basicConfig(level=logging.DEBUG,
                    format=log_format,
                    datefmt=date_format)


class FindSecondComponent(object):

    def __init__(self):
        self.log = logging.getLogger(__name__)
        self.args = None
        self.target_list = None
        self.template_list = None
        self.first_component = None

    def __call__(self, *args, **kwargs):
        self.log.info("hello! this is a log message")
        self.args = self._get_args()
        print(self.args)

    def spbina(self):
        pass

    @staticmethod
    def _get_args(arguments=None):
        parser = argparse.ArgumentParser(
            description="Finds secondary component of binary stars")

        # parser.add_argument('--debug',
        #                     action='store_true',
        #                     dest='debug_mode',
        #                     help='Run in debug mode')

        parser.add_argument('--file-list',
                            action='store',
                            type=str,
                            dest='file_list',
                            help='List of Observed spectra')

        parser.add_argument('--template-list',
                            action='store',
                            type=str,
                            dest='template_list',
                            help='List of Templates')

        parser.add_argument('--primary',
                            action='store',
                            default='A',
                            type=str,
                            dest='primary_output_file',
                            help='Output name for primary component spectrum')

        parser.add_argument('--secondary',
                            action='store',
                            default='B',
                            type=str,
                            dest='secondary_output_file',
                            help='Output name for secondary component spectrum')

        parser.add_argument('--vo',
                            action='store',
                            default=25,
                            type=float,
                            dest='vo',
                            help='vgamma')

        parser.add_argument('--min-mass-ratio',
                            action='store',
                            default=0.02,
                            type=float,
                            dest='min_mass_ratio',
                            help='Minimum mass ratio')

        parser.add_argument('--max-mass-ratio',
                            action='store',
                            default=0.5,
                            type=float,
                            dest='max_mass_ratio',
                            help='Maximum mass ratio')

        parser.add_argument('--mass-ratio-step',
                            action='store',
                            default=0.01,
                            type=float,
                            dest='mass_ratio_step',
                            help='Mass ratio step')

        parser.add_argument('--sam',
                            action='store',
                            default='*',
                            type=str,
                            dest='sam',
                            help='Spectral regions')

        args = parser.parse_args(args=arguments)

        return args


if __name__ == '__main__':
    find2c = FindSecondComponent()
    find2c()

