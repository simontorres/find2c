from ccdproc import CCDData
import ccdproc
from astropy.io import fits
from astropy.io.fits.verify import VerifyError

import os
import logging

class SpbinA(object):

    def __init__(self):
        self.log = logging.getLogger(__name__)
        self.input_list = None
        self.primary_star = None
        self.secondary_star = None
        self.iters = 4
        self.combine = 'average'
        self.reject = 'sigclip'
        self.weight_list = None
        self.do_all = False

    def __call__(self, input_list,
           primary_star,
           secondary_star,
           iters=4,
           combine='average',
           reject='sigclip',
           weights=1,
           do_all=False):

        self._get_file_list(input_list)
        self._get_weights(file_name=weights)

        self._fix_headers()

        if len(self.weight_list) != len(self.input_list):
            print("The length of weights and input list does not match.")

        if os.path.isfile(secondary_star):
            self.secondary_star = secondary_star
        else:
            self.log.error('Unable to find secondary star spectrum file')
        print(self.input_list)
        print(self.weight_list)

    @staticmethod
    def _load_txt_file(file_name):
        with open(file_name, 'r') as file_list:
            file_content = file_list.read().split('\n')
            file_list.close()
            return file_content

    def _fix_headers(self):
        for _file in self.input_list:
            print(_file)
            try:
                header = fits.getheader(_file)
                print(fits.getval(_file, 'ST'))
                data = fits.getdata(_file)

                ccd = CCDData(data=data, header=header, unit='adu')
                ccd.write(_file, overwrite=True)
            except VerifyError as error:
                print(error)

    def _get_weights(self, file_name):
        if file_name == 1:
            self.weight_list = [1] * len(self.input_list)
        elif isinstance(file_name, str) and os.path.isfile(file_name):
            self.weight_list = self._load_txt_file(file_name=file_name)

    def _get_file_list(self, input_list):
        if os.path.isfile(input_list):
            self.input_list = self._load_txt_file(input_list)
        else:
            print("Error, file {:s} does not exist".format(input_list))
        # self.input_list = ['file{:d}.fits'.format(i) for i in range(9)]





if __name__ == '__main__':
    instance_of_spbina = SpbinA()
    instance_of_spbina(input_list='file_list.txt', primary_star='a', secondary_star='b')
