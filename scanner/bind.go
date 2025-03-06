package scanner

// Result is a simplified version of ScanResult for mobile binding
type Result struct {
	BucketName   string
	IsPublic     bool
	Permissions  string
	Error        string
	ResponseTime int64
}

// ScannerBridge provides a simplified interface for mobile platforms
type ScannerBridge struct {
	scanner *Scanner
}

// NewScannerBridge creates a new ScannerBridge instance
func NewScannerBridge() *ScannerBridge {
	return &ScannerBridge{
		scanner: NewScanner(),
	}
}

// ScanSingleBucket scans a single bucket and returns the result
func (sb *ScannerBridge) ScanSingleBucket(bucketName string) *Result {
	scanResult := sb.scanner.ScanBucket(bucketName)
	return &Result{
		BucketName:   scanResult.BucketName,
		IsPublic:     scanResult.IsPublic,
		Permissions:  scanResult.Permissions,
		Error:        scanResult.Error,
		ResponseTime: scanResult.ResponseTime,
	}
}

// ScanMultipleBuckets scans multiple buckets and returns the results
func (sb *ScannerBridge) ScanMultipleBuckets(bucketNames []string) []Result {
	scanResults := sb.scanner.ScanBuckets(bucketNames)
	results := make([]Result, len(scanResults))
	
	for i, sr := range scanResults {
		results[i] = Result{
			BucketName:   sr.BucketName,
			IsPublic:     sr.IsPublic,
			Permissions:  sr.Permissions,
			Error:        sr.Error,
			ResponseTime: sr.ResponseTime,
		}
	}
	
	return results
}

// SetUserAgent sets the User-Agent string for requests
func (sb *ScannerBridge) SetUserAgent(userAgent string) {
	sb.scanner.UserAgent = userAgent
}

// SetTimeout sets the timeout for requests in seconds
func (sb *ScannerBridge) SetTimeout(seconds int) {
	sb.scanner.TimeoutSec = seconds
}
