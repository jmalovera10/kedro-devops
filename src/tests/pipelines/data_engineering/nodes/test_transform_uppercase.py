import pandas as pd

from kedro_devops.pipelines.data_engineering.nodes.transform_uppercase import (
    transform_uppercase,
)


class TestTransformUppercase:
    def test_transform_string(self):
        """
        should return a upper case string for a string dataframe
        """
        t_dataframe = pd.DataFrame({"names": ["juan", "manuel", "alberto"]})
        output = transform_uppercase(t_dataframe)
        assert output.equals(pd.DataFrame({"names": ["JUAN", "MANUEL", "ALBERTO"]}))
