update:
	tccli cvm DescribeRegions | jq -r '.RegionSet | map({Region, RegionName})' > region.json
