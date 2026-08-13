$ErrorActionPreference = 'Stop'
$app = Get-Content -Raw 'Gerenciamento_Financeiro.html'
$url = [regex]::Match($app, "SUPABASE_URL_PADRAO = '([^']+)'").Groups[1].Value
$key = [regex]::Match($app, "SUPABASE_KEY_PADRAO = '([^']+)'").Groups[1].Value
if (!$url -or !$key) { throw 'Não foi possível localizar a conexão do Supabase no sistema.' }
$headers = @{ apikey = $key; Authorization = "Bearer $key" }

function SqlValue($value, $json = $false) {
  if ($null -eq $value) { return $(if ($json) { "'[]'::jsonb" } else { 'NULL' }) }
  if ($json) { return "'" + (($value | ConvertTo-Json -Compress -Depth 20) -replace "'", "''") + "'::jsonb" }
  if ($value -is [bool]) { return $value.ToString().ToUpperInvariant() }
  if ($value -is [byte] -or $value -is [int] -or $value -is [long] -or $value -is [decimal] -or $value -is [double]) { return [Convert]::ToString($value, [Globalization.CultureInfo]::InvariantCulture) }
  return "'" + ([string]$value -replace "'", "''") + "'"
}

function GetRows($table) {
  return @(Invoke-RestMethod -Uri "$url/rest/v1/$table`?select=*" -Headers $headers -Method Get)
}

$tables = @{
  com_atendentes = @{ target='comissao_atendentes'; columns=@('id','nome','tipo','valor','created_at') }
  com_vendas = @{ target='comissao_vendas'; columns=@('id','data','os','cliente','produto','atendente','valor','pagamento','status','obs','com_tipo','com_valor','valor_recebido','valor_comissao_baixada','data_baixa_comissao','obs_baixa','historico_baixas','historico_recebimentos','created_at') }
  com_recebimentos = @{ target='comissao_recebimentos'; columns=@('id','cliente','tipo','recorrencia','valor','data_prevista','dia','inicio','created_at') }
  com_produtos = @{ target='comissao_produtos'; columns=@('nome','created_at') }
  com_config = @{ target='comissao_config'; columns=@('key','value','updated_at') }
}

$out = New-Object System.Collections.Generic.List[string]
$out.Add('-- Backup gerado em ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
$out.Add('-- Importe este arquivo no SQL Editor de um novo projeto Supabase.')
$out.Add((Get-Content -Raw 'supabase_schema.sql'))
$out.Add('BEGIN;')

foreach ($table in @('com_atendentes','com_produtos','com_recebimentos','com_vendas','com_config')) {
  $rows = GetRows $table
  $targetTable = $tables[$table].target
  $columns = $tables[$table].columns
  $keyColumn = if ($table -eq 'com_produtos') { 'nome' } elseif ($table -eq 'com_config') { 'key' } else { 'id' }
  foreach ($row in $rows) {
    $values = foreach ($column in $columns) {
      $value = $row.$column
      if ($table -eq 'com_vendas' -and $column -eq 'historico_baixas' -and $null -eq $value) {
        $obsBaixa = if ($null -eq $row.obs_baixa) { '' } else { $row.obs_baixa }
        $value = if ($row.data_baixa_comissao -and [decimal]$row.valor_comissao_baixada -gt 0) { @(@{ data=$row.data_baixa_comissao; valor=$row.valor_comissao_baixada; obs=$obsBaixa }) } else { @() }
      }
      if ($table -eq 'com_vendas' -and $column -eq 'historico_recebimentos' -and $null -eq $value) {
        $dataRecebimento = if ($row.data_baixa_comissao) { $row.data_baixa_comissao } else { $row.data }
        $value = if ([decimal]$row.valor_recebido -gt 0) { @(@{ data=$dataRecebimento; valor=$row.valor_recebido; obs='' }) } else { @() }
      }
      SqlValue $value ($column -in @('historico_baixas','historico_recebimentos','value'))
    }
    $updates = ($columns | Where-Object { $_ -ne $keyColumn } | ForEach-Object { "$_ = EXCLUDED.$_" }) -join ', '
    $out.Add("INSERT INTO $targetTable (" + ($columns -join ', ') + ') VALUES (' + ($values -join ', ') + ") ON CONFLICT ($keyColumn) DO UPDATE SET $updates;")
  }
}
$out.Add('COMMIT;')
$destination = Join-Path (Get-Location) 'backup_supabase_comissao.sql'
[IO.File]::WriteAllLines($destination, $out, [Text.UTF8Encoding]::new($false))
Write-Output "Backup criado: $destination"
