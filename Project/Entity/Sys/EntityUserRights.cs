using System;
namespace project.Entity.Sys
{
    /// <summary>用户权限分配</summary>
    /// <author>tz</author>
    /// <date>2016-2-18</date>
    [System.Serializable]
    public class EntityUserInfoRights
    {
        private string _entityOID;
        private string _menuName;
        private string _menuType;
        private string _menuPath;
        private int _flag;
        private string _parent;
        private string _orderNo;
        private bool _right;
        private string _rightCode;
        private string _rightName;
        private string _haveRightName;

        /// <summary>缺省构造函数</summary>
        public EntityUserInfoRights() { }

        /// <summary>主键，只读属性</summary>
        public System.Guid EntityOID
        {
            get { return new System.Guid(_entityOID); }
        }

        /// <summary>内部映射主键</summary>
        public string InnerEntityOID
        {
            get { return _entityOID; }
            set { _entityOID = value; }
        }

        /// <summary>
        /// 功能描述：菜单名称
        /// 长度：100
        /// 不能为空：否
        /// </summary>
        public string MenuName
        {
            get { return _menuName; }
            set { _menuName = value; }
        }

        /// <summary>
        /// 功能描述：菜单类型
        /// 长度：30
        /// 不能为空：否
        /// </summary>
        public string MenuType
        {
            get { return _menuType; }
            set { _menuType = value; }
        }

        /// <summary>
        /// 功能描述：菜单路径
        /// 长度：200
        /// 不能为空：否
        /// </summary>
        public string MenuPath
        {
            get { return _menuPath; }
            set { _menuPath = value; }
        }

        /// <summary>
        /// 功能描述：层级
        /// 不能为空：否
        /// </summary>
        public int Flag
        {
            get { return _flag; }
            set { _flag = value; }
        }

        /// <summary>
        /// 功能描述：父节点
        /// 长度：50
        /// 不能为空：否
        /// </summary>
        public string Parent
        {
            get { return _parent; }
            set { _parent = value; }
        }

        /// <summary>
        /// 功能描述：排序字段
        /// 长度：30
        /// 不能为空：否
        /// </summary>
        public string OrderNo
        {
            get { return _orderNo; }
            set { _orderNo = value; }
        }

        /// <summary>
        /// 功能描述：操作权限编码
        /// </summary>
        public string RightCode
        {
            get { return _rightCode; }
            set { _rightCode = value; }
        }

        /// <summary>
        /// 功能描述：操作权限名称
        /// </summary>
        public string RightName
        {
            get { return _rightName; }
            set { _rightName = value; }
        }

        /// <summary>
        /// 功能描述：拥有操作权限名称
        /// </summary>
        public string HaveRightCode
        {
            get { return _haveRightName; }
            set { _haveRightName = value; }
        }

        /// <summary>
        /// 功能描述：是否有权限
        /// </summary>
        public bool Right
        {
            get { return _right; }
            set { _right = value; }
        }
    }
}
