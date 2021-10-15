import pandas as pd

from kedro_devops.pipelines.data_engineering.nodes.upper_caser import upper_caser


def test_upper_caser():
    basic_data = pd.DataFrame({'names': ['juan', 'manuel', 'alberto']})
    output = upper_caser(basic_data)
    
    assert output.equals(pd.DataFrame({'names': ['JUAN', 'MANUEL', 'ALBERTO']}))
