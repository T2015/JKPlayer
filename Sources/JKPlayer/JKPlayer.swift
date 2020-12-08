import UIKit
import AVKit


open class JKPlayer: AVPlayer {
    
    
    /// 播放状态
    public enum PlayStatus: Equatable {
        
        case unknown        // 未知，初始化后默认状态
        case waitToPlay     // 等待播放，资源加载完毕
        case playing        // 正在播放
        case pause          // 暂停
        case end            // 结束
        case error(String)  // 错误，资源错误等
    }
    
    
    public static let share: JKPlayer = JKPlayer()
    
    public var playStatus: PlayStatus = .unknown {
        didSet{
            NotificationCenter.default.post(name: JKPlayer.playStatusDidChangeNoticeName, object: self)
        }
    }
    
    public var totalTime: Int {
        
        guard let item = self.currentItem else { return 0 }
        return Int(CMTimeGetSeconds(item.duration))
    }
    
    override init() {
        
        super.init()
        self.actionAtItemEnd = .none
        addObserve()
    }
    
    deinit {
        removeObserve()
    }
    
    public func replaceCurrentUrl(_ url: String) {
        
        guard let tmp = URL(string: url) else { return }
        let item = AVPlayerItem(url: tmp)
        replaceCurrentItem(with: item)
    }
    
    public override func play() {
        guard let _ = currentItem else { return }
        if playStatus == .pause || playStatus == .waitToPlay || playStatus == .end {
            playStatus = .playing
            super.play()
        }
        
    }
    
    public override func pause() {
        guard let _ = currentItem else { return }
        if playStatus == .playing {
            playStatus = .pause
            super.pause()
        }
    }
    
    
    func addObserve() {
        
        addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { (time) in
            NotificationCenter.default.post(name: JKPlayer.timeDidChangeNoticeName, object: self)
        }
        addObserver(self, forKeyPath: "status", options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(interruption(notice:)), name: AVAudioSession.interruptionNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(mediaServicesWereLost(notice:)), name: AVAudioSession.mediaServicesWereLostNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(mediaServicesWereReset(notice:)), name: AVAudioSession.mediaServicesWereResetNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(silenceSecondaryAudioHint(notice:)), name: AVAudioSession.silenceSecondaryAudioHintNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive(notice:)), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEndTime(notice:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func removeObserve() {
        removeObserver(self, forKeyPath: "status")
        NotificationCenter.default.removeObserver(self)
    }
    
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (keyPath == "status") {
            guard let info = change else { return }
            guard let status = info[NSKeyValueChangeKey.newKey] as? Int else { return }
            if status == 1 {
                playStatus = .waitToPlay
            }else if status == 2 {
                playStatus = .error("播放器异常")
            }else if status == 0 {
                playStatus = .unknown
            }
        }
        
    }
    
    @objc func interruption(notice: Notification) {
        guard let ply = notice.object as? JKPlayer else { return }
        if ply != self {
            return
        }
        pause()
        playStatus = .pause
    }
    
    @objc func mediaServicesWereLost(notice: Notification) {
        guard let ply = notice.object as? JKPlayer else { return }
        if ply != self {
            return
        }
        pause()
        playStatus = JKPlayer.PlayStatus.error("mediaServicesWereLost")
    }
    
    @objc func mediaServicesWereReset(notice: Notification) {
        guard let ply = notice.object as? JKPlayer else { return }
        if ply != self {
            return
        }
        pause()
        playStatus = JKPlayer.PlayStatus.error("mediaServicesWereReset")
    }
    
    @objc func silenceSecondaryAudioHint(notice: Notification) {
        guard let ply = notice.object as? JKPlayer else { return }
        if ply != self {
            return
        }
//        pause()
//        playStatus = JKPlayer.PlayStatus.pause
    }
    
    @objc func didPlayToEndTime(notice: Notification) {
        guard let item = notice.object as? AVPlayerItem else { return }
        if item != currentItem {
            return
        }
        pause()
        playStatus = JKPlayer.PlayStatus.end
        let time = CMTimeMake(value: 0, timescale: 1)
        item.seek(to: time)
    }
    
    @objc func willResignActive(notice: Notification) {
        if playStatus == .playing {
            pause()
            playStatus = JKPlayer.PlayStatus.pause
        }
        
    }
    
    
    public static let playStatusDidChangeNoticeName: NSNotification.Name = NSNotification.Name(rawValue: "JKPlayer.playStatusDidChange")
    public static let timeDidChangeNoticeName: NSNotification.Name = NSNotification.Name(rawValue: "JKPlayer.timeDidChangeNoticeName")
    
}












