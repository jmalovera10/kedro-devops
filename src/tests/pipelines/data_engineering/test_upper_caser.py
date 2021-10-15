import pandas as pd

from kedro_devops.pipelines.data_engineering.nodes.upper_caser import upper_caser


class TestUpperCaser:
    def should_upper_case_string_data(self):
        """Should upper case string data"""
        basic_data = pd.DataFrame({'names': ['juan', 'manuel', 'alberto']})
        output = upper_caser(basic_data)
        
        assert output.equals(pd.DataFrame({'names': ['JUAN', 'MANUEL', 'ALBERTO']}))

    def should_not_upper_case_number_data(self):
        """Should not upper case number data"""
        basic_data = pd.DataFrame({'numbers': [1, 2, 3]})
        output = upper_caser(basic_data)
        
        assert output.equals(pd.DataFrame({'numbers': [1, 2, 3]}))
