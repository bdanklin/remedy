defmodule Remedy.Telemetry do
  @moduledoc """
  hello

  <div class="mermaid">
  graph TD;
  classDef server fill:#D0B441,stroke:#AD9121,stroke-width:1px;
  classDef topic fill:#B5ADDF,stroke:#312378,stroke-width:1px;
  classDef db fill:#9E74BE,stroke:#4E1C74,stroke-width:1px;
  T1(TopicA):::topic --> G1{{GenServerA}}:::server;
  T1(TopicA):::topic --> G2{{GenServerB}}:::server;
  G2{{GenServerB}}:::server --> T2(TopicB):::topic;
  T2(TopicB):::topic ==> DB[("Storage")]:::db;
  </div>
  """
end
