import pandas as pd
from pytest import MonkeyPatch
from requests.models import Response

from kedro_devops.pipelines.data_engineering.nodes.transform_uppercase import (
    transform_uppercase,
)


class TestTransformUppercase:
    def test_transform_string(self, monkeypatch: MonkeyPatch):
        """
        should return a upper case string for a string dataframe
        """

        def mock_json():
            return {
                "results": [{"data": "test1"}, {"data": "test2"}, {"data": "test3"}]
            }

        response = Response()
        monkeypatch.setattr(response, "json", mock_json)
        output = transform_uppercase(response)
        assert output.equals(pd.DataFrame({"data": ["TEST1", "TEST2", "TEST3"]}))
